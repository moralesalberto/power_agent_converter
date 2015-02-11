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

  class Row
    def initialize(row)
      @row = row
    end

    def target_power
      @row[2]
    end

    def duration_units
      @row[1].to_s
    end

    def minutes
      duration_units.match(/\d+/)[0].to_i
    end

    def seconds
      duration_units.match(/\:(\d+)/)[1].to_i
    end

    def duration
      (minutes*60)+seconds
    end
  end
end
