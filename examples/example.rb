$: << "../lib"
require 'configdsl'

# Read external data
ConfigDSL.read("test.cdsl.rb")

# Execute inline data
ConfigDSL.execute do
  inline_loading_example "here goes"
  value "awesome"
  code "great"
  block_test "config option" do |preset|
    block_val preset
  end
end

# Another inline data
ConfigDSL.execute do
  value "awesome"
end

require "pp" # for pretty print

# Here is how you get all the config
pp ConfigDSL.data

# To read data from your app you can do this:

puts ; puts "Value of :value is: "
p ConfigDSL.data[:value]

# or this

puts ; puts "Another way to get it is: "
p ConfigDSL[:value]

# Access block values

puts ; puts "Block values: "

puts ; puts "-- [:list][:one]"
p ConfigDSL[:list][:one]

puts ; puts "-- [:list][:two]"
p ConfigDSL[:list][:two]

puts ; puts "-- [:list][:three]"
p ConfigDSL[:list][:three]

puts ; puts "-- [:list][:three][:three_two]"
p ConfigDSL[:list][:three][:three_two]

# Get something complex
puts ; puts "Program was stared at: "
p ConfigDSL[:starting_time]

