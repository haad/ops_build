require "rsd_rake/version"

require 'rsd_rake/berkshelf'
require 'rsd_rake/chefspec'
require 'rsd_rake/kitchen'
require 'rsd_rake/packer'
require 'rsd_rake/rsd_task_lib'
require 'rsd_rake/vagrant'

require 'rake'

lib = File.expand_path('.', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

module RsdRake
  class BuildTask
    include Rake::DSL if defined? Rake::DSL
    def install_tasks
       load 'rsd_rake/tasks/build.rake'
    end
  end
end

RsdRake::BuildTask.new.install_tasks
