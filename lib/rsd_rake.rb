require "rsd_rake/version"
require 'rake'


module RsdRake
  class BuildTask
    include Rake::DSL if defined? Rake::DSL
    def install_tasks
       load 'rsd_rake/tasks/build.rake'
    end
  end
end

RsdRake::BuildTask.new.install_tasks
