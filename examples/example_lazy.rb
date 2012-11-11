$: << "../lib"
require 'configdsl'

ConfigDSL.execute do
  lazy_varaible lazy!{ Time.now }
  standart_variable Time.now
  
  lower_level_also_works do
    lazy_time lazy!{ Time.now }
  end
  
  delta lazy!(Time.now){ |config_reading_time| Time.now.to_i - config_reading_time.to_i }
end

# We sleep for time to change
sleep 2

print "Standart: "
p ConfigDSL.standart_variable

print "Lazy: "
p ConfigDSL.lazy_varaible

print "Lazy (another way to get): "
p ConfigDSL[:lazy_varaible]

print "Lazy (force LazyValue object instead of its content): "
p ConfigDSL.original_reader(:lazy_varaible)

print "Non-toplevel lazy variables (only evaluated on request): "
p ConfigDSL.lower_level_also_works

print "And this value processed: "
p ConfigDSL.lower_level_also_works.lazy_time

print "Delta between lazy and standart Time.now (should -> 2): "
p ConfigDSL.delta
