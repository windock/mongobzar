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
  gem.add_development_dependency('ruby-debug19')
  gem.add_development_dependency('rr')

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mongobzar"
  gem.require_paths = ["lib"]
  gem.version       = Mongobzar::VERSION
end
