# -*- encoding: utf-8 -*-
require File.expand_path('../lib/configdsl/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["MOZGIII"]
  gem.email         = ["mike-n@narod.ru"]
  gem.description   = %q{A convinient Ruby-based DSL for your app configuration!}
  gem.summary       = %q{A convinient Ruby-based DSL for your app configuration!}
  gem.homepage      = "http://github.com/MOZGIII/ConfigDSL"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "configdsl"
  gem.require_paths = ["lib"]
  gem.version       = Configdsl::VERSION
  
  gem.add_runtime_dependency "activesupport"
end
