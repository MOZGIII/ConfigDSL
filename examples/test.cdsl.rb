# Simple example
hi "User"
# p hi  # => "User"

# Local variables still work!
local_var = "it is me"
another_var = "not included in config but can be used as usual"

# Complex example
list do
  one "123"
  two "345"
  three do
    one "1"
    three_two one + " 2"
    three_three "three"
  end
  see "will_be_ovewritten"
end

list 5 do |index|
  append "anything"
  second index + 1
  square index ** 2
  
  see "overwritten!"
end

starting_time Time.now
