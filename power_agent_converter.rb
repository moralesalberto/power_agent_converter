require 'bundler/setup'
require 'csv'
require 'erb'
require 'byebug'

# This class will read the contexts of the excel file
# and output xml for power agent using an erb template
class PowerAgentConverter
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def basename
    filename.gsub('.csv','')
  end

  def csv_rows
    @workbook ||= CSV.parse(File.read(filename))
  end

  def rows
    csv_rows.each_with_index.map {|row, i| Row.new(row) if i > 0 }.compact
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
    def initialize(row)
      @row = row
    end

    # watts
    # 256
    # 120
    def target_power
      @row[2]
    end

    # minutes and seconds
    # 10:03
    #  3:01
    #  5:00
    #  0:15
    def duration_units
      @row[1].to_s
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
