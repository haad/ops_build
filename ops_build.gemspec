# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ops_build/version'

Gem::Specification.new do |spec|
  spec.name          = 'ops_build'
  spec.version       = OpsBuild::VERSION
  spec.authors       = ['HAMSIK Adam']
  spec.email         = ['adh@rsd.com']
  spec.summary       = %q(RSD Devops related build tool to run packer, berkshelf)
  spec.description   = %q(RSD Devops related build tool to run packer, berkshelf)
  spec.homepage      = 'http://www.rsd.com'
  spec.license       = 'BSD'

  spec.required_ruby_version = '>= 2.1.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'thor', '~> 0.19.1'

  spec.add_development_dependency 'bundler', '~> 1.6'
end
