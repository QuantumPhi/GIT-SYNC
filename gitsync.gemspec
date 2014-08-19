# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require './lib/version.rb'

Gem::Specification.new do |spec|
  spec.name          = "gitsync"
  spec.version       = GITSYNC::VERSION
  spec.authors       = ["Tarik Onalan"]
  spec.email         = ["phi.quantum@gmail.com"]
  spec.summary       = "Synchronize gitconfigs across devices."
  spec.description   = "Gone are the days of raging at missing aliases."
  spec.homepage      = "https://quantumphi.github.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'json', '~> 1.8'
  spec.add_dependency 'rest-client', '~> 1.7'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
