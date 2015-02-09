# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ops_build/version'

Gem::Specification.new do |spec|
  spec.name          = 'ops_build'
  spec.version       = OpsBuild::VERSION
  spec.authors       = ['HAMSIK Adam']
  spec.email         = ['adh@rsd.com']
  spec.summary       = %q{RSD Devops related build tool to run packer, berkshelf}
  spec.description   = %q{RSD Devops related build tool to run packer, berkshelf}
  spec.homepage      = "http://www.rsd.com"
  spec.license       = 'BSD'

  spec.files         = `git ls-files -z`.split("\x0")
  #spec.files = Dir['{bin/*,lib/**/*}'] + %w(ops_build.gemspec Rakefile README.md LICENSE.txt Gemfile)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_path = 'lib'
  #spec.require_paths = ['lib']

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "thor"
  spec.add_development_dependency "pry"

  #spec.add_dependency 'erubis'
  #spec.add_dependency 'json'
end
