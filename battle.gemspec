# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'battle/version'

Gem::Specification.new do |spec|
  spec.name          = "battle"
  spec.version       = Battle::VERSION
  spec.authors       = ["Vitaly Tatarintsev"]
  spec.email         = ["Kalastiuz@gmail.com"]
  spec.description   = %q{Battle vs Platform45}
  spec.summary       = %q{Wrapper to Platform45 developer challenge API http://battle.platform45.com/}
  spec.homepage      = "http://github.com/ck3g/battle"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client", "~> 1.6.7"
  spec.add_dependency "json", "~> 1.7.7"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock", "~> 1.9.0"
end
