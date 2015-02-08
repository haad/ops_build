# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rsd_rake/version'

Gem::Specification.new do |spec|
  spec.name          = "rsd_rake"
  spec.version       = RsdRake::VERSION
  spec.authors       = ["HAMSIK Adam"]
  spec.email         = ["adh@rsd.com"]
  spec.summary       = %q{RSD Devops related Rake tasks to run packer, berkshelf}
  spec.description   = %q{RSD Devops related Rake tasks to run packer, berkshelf}
  spec.homepage      = ""
  spec.license       = "BSD"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
