# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omnistore/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["arukoh"]
  gem.email         = ["arukoh10@gmail.com"]
  gem.description   = %q{Providers a single point of entry for storage}
  gem.summary       = %q{Providers a single point of entry for storage}
  gem.homepage      = "https://github.com/arukoh/omnistore"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "omnistore"
  gem.require_paths = ["lib"]
  gem.version       = OmniStore::VERSION

  gem.add_dependency "aws-sdk", ">=1.6.0"
  gem.add_dependency "activesupport"

  gem.add_development_dependency "rake", ">= 0.8.7"
  gem.add_development_dependency "rspec", ">= 2.4.0"
end
