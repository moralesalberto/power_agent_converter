require_relative 'power_agent_converter.rb'

puts "Enter the path to the html file:"

filename = gets.chomp

puts "Enter the original ftp:"
original_ftp = gets.chomp.to_i.to_f

puts "Enter the output ftp:"
output_ftp = gets.chomp.to_i.to_f

ftp_conversion_factor = output_ftp/original_ftp

p = PowerAgentConverter.new(filename, ftp_conversion_factor)

p.to_file

puts "The file was converted to: #{p.output_filename}"
