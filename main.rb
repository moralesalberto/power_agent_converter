require_relative 'power_agent_converter.rb'

puts "Enter the path to the html file:"

filename = gets.chomp

p = PowerAgentConverter.new(filename)

p.to_file

puts "The file was converted to: #{p.output_filename}"
