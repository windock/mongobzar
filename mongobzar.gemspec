# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mongobzar/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Shcheglov"]
  gem.email         = ["ash@translucent.dk"]
  gem.description   = %q{Write a gem description}
  gem.summary       = %q{Write a gem summary}
  gem.homepage      = ""

  gem.add_dependency('bson_ext')
  gem.add_dependency('rake')
  gem.add_dependency('mongo')
  gem.add_development_dependency('debugger')
  gem.add_development_dependency('rspec')

  gem.files         = Dir['lib/**/*.rb']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mongobzar"
  gem.require_paths = ["lib"]
  gem.version       = Mongobzar::VERSION
end
