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
    doc.search('//table')
  end

  def data_table
    html_tables[5]
  end

  def html_rows
    data_table.search('tr')[1..-1]
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
  attr_reader :filename

  def initialize(filename)
    @filename = filename
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
        _rows = data_rows.each_with_index.map {|row, i| Row.new(row) if row.size == 25 }.compact # remove any rows that do not have 25 cells
      end
  end

  def erb_template
    File.read('total_cyclist.xml.erb')
  end

  def output
    ERB.new(erb_template).result(binding)
  end

  def to_file
    File.open("#{basename}.xml", "w") { |file| file.puts output }
  end

  class Row
    attr_reader :cells
    def initialize(cells)
      @cells = cells
    end

    # watts
    # 256
    # 120
    def target_power
      @cells[15]
    end

    # minutes and seconds
    # 10:03
    #  3:01
    #  5:00
    #  0:15
    def duration_units
      @cells[3]
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
