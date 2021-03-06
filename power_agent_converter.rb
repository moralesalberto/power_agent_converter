require 'bundler/setup'
require 'nokogiri'
require 'erb'
require 'byebug'


class HtmlParser
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def doc
    @doc ||= Nokogiri::HTML(File.read(filename))
  end

  def html_tables
    doc.search('//table[@class="tableSmall"]')
  end

  def data_table
    html_tables[0]
  end

  def html_rows
    data_table.search('tr')
  end

  # this returns an array of rows
  # with each row having an array of cells
  def data_rows
    html_rows.each_with_index.map do |row, i|
      next unless i > 0
      next if i+1 == html_rows.size
      row.search('td//text()').map { |cell| CGI.unescapeHTML(cell.to_s.strip) }
    end.compact
  end
end

# This class will take the html rows and output the corresponding erb file
class PowerAgentConverter
  attr_reader :filename, :ftp_conversion_factor

  def initialize(filename, ftp_conversion_factor)
    @filename = filename
    @ftp_conversion_factor = ftp_conversion_factor
  end

  def basename
    filename.gsub('.html','')
  end

  def data_rows
    @data_rows ||= HtmlParser.new(filename).data_rows
  end

  def rows
    @rows ||=
      begin
        _rows = data_rows.each_with_index.map {|cells, i| puts "[#{i}, #{cells.size}, #{cells[3]}]"; Row.new(cells, ftp_conversion_factor) }.compact # remove any rows that do not have 25 cells
      end
  end

  def erb_template
    File.read('total_cyclist.xml.erb')
  end

  def output
    ERB.new(erb_template).result(binding)
  end

  def output_filename
    "#{basename}.xml"
  end

  def to_file
    File.open(output_filename, "w") { |file| file.puts output }
  end

  class Row
    attr_reader :cells, :ftp_conversion_factor
    def initialize(cells, ftp_conversion_factor)
      @cells = cells
      @ftp_conversion_factor = ftp_conversion_factor
    end

    # seems like the report sometimes has different row sizes
    def power_cell
      case @cells.size
      when 24
        @cells[14]
      when 26
        @cells[16]
      when 27
        @cells[17]
      when 25
        @cells[15]
      else
        raise "error with file; number of cells #{cells.size}\n#{cells.inspect} unexpected"
      end
    end

    # watts
    # 256
    # 120
    def target_power
      (power_cell.to_i.to_f * ftp_conversion_factor).to_i
    end

    # minutes and seconds
    # 10:03
    #  3:01
    #  5:00
    #  0:15
    def duration_units
      case @cells.size
      when 24
        @cells[2]
      when 25
        @cells[3]
      when 26
        @cells[2]
      when 27
        @cells[2]
      end
    end

    def minutes
      duration_units.match(/\d+/)[0].to_i
    end

    def seconds
      duration_units.match(/\:(\d+)/)[1].to_i
    end

    # we want seconds for the xml file to import
    def duration
      (minutes*60)+seconds
    end
  end
end
