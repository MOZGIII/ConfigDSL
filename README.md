# ConfigDSL

A tasty DSL for configuration files. Get rid of those ugly YAML and JSON configs.

## Installation

Add this line to your application's Gemfile:

    gem 'configdsl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install configdsl

## Usage

### Standalone Usage

#### To read a config file

 - in your app:

```ruby
# Read external data
ConfigDSL.read("test.cdsl.rb")
```

 - test.cdsl.rb

```ruby
hi "User"
# p hi  # => "User"

list do
  one "123"
  two "345"
  three do
    one "1"
    three_two one + " 2"
    three_three "three"
  end
  see "will_be_overwritten"
end

list 5 do |index|
  append "anything"
  second index + 1
  square index ** 2
  
  see "overwritten!"
end

starting_time Time.now
```

   will produce

```ruby
pp ConfigDSL.data

{:hi=>"User",
 :list=>
  {:one=>"123",
   :two=>"345",
   :three=>{:one=>"1", :three_two=>"1 2", :three_three=>"three"},
   :see=>"overwritten!",
   :append=>"anything",
   :second=>6,
   :square=>25},
 :starting_time=>2012-11-05 22:47:36 +0000}
```

#### You can also load inline configs form your code

```ruby
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
```
    
   gives

```ruby
{:inline_loading_example=>"here goes",
 :value=>"awesome",
 :code=>"great",
 :block_test=>{:block_val=>"config option"}}
```


#### You can combine theese two

```ruby
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
pp ConfigDSL.data
```

   is

```ruby
{:hi=>"User",
 :list=>
  {:one=>"123",
   :two=>"345",
   :three=>{:one=>"1", :three_two=>"1 2", :three_three=>"three"},
   :see=>"overwritten!",
   :append=>"anything",
   :second=>6,
   :square=>25},
 :starting_time=>2012-11-05 22:48:40 +0000,
 :inline_loading_example=>"here goes",
 :value=>"awesome",
 :code=>"great",
 :block_test=>{:block_val=>"config option"}}
```

#### You can coviniently access all the config values in your app

```ruby
# Here is how you get all the config
p ConfigDSL.data

# To read data from your app you can do this:

puts ; puts "Value of :value is: "
p ConfigDSL.data[:value]

# or this

puts ; puts "Another way to get it is: "
p ConfigDSL[:value]

# Access block values

puts "Block values: "

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
```

#### Check out the example!

There is an `examples` dir. Check it out to see how it works for yourself!

### Use Hashie::Mash

If you're using Hashie::Mash from https://github.com/intridea/hashie, it will be used to store the config.
Just make sure to require it before you read the first value.


### Ruby on Rails

To be implemented. For now you can use it like standalone as initializer.

### To-Do List

 - Ruby on Rails integration
 - Lazy config values

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
