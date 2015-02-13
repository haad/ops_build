require 'rubygems'

require 'fileutils'
require 'json'
require 'rbconfig'
require 'tempfile'
require 'thor'
require 'yaml'

lib = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'ops_build/commands/build'
require 'ops_build/commands/kitchen'
require 'ops_build/commands/validate'
require 'ops_build/runner'
require 'ops_build/version'
require 'ops_build/aws'
require 'ops_build/berkshelf'
require 'ops_build/chefspec'
require 'ops_build/kitchen'
require 'ops_build/packer'
require 'ops_build/vagrant'

module OpsBuild

end
