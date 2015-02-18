require 'rubygems'

require 'fileutils'
require 'json'
require 'rbconfig'
require 'tmpdir'
require 'thor'
require 'open3'
require 'yaml'
require 'logger'
require 'digest'

lib = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'ops_build/commands/build'
require 'ops_build/commands/generate'
require 'ops_build/commands/kitchen'
require 'ops_build/commands/validate'
require 'ops_build/box_indexer'
require 'ops_build/runner'
require 'ops_build/version'
require 'ops_build/aws'
require 'ops_build/berkshelf'
require 'ops_build/chefspec'
require 'ops_build/kitchen'
require 'ops_build/packer'
require 'ops_build/vagrant'
require 'ops_build/validations'
require 'ops_build/utils'

module OpsBuild
  def self.logger
    if @logger.nil?
      @logger = Logger.new(STDOUT)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{severity}] [#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{msg.strip}\n"
      end
      @logger.level = Logger::INFO
    end

    @logger
  end
end
