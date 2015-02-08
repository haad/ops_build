require 'rubygems'
require 'rake'
require 'yaml'
require 'json'
require 'tempfile'
require 'rbconfig'
require 'fileutils'

require 'erubis'

require 'chef/cookbook/metadata'

rsd_rake = RsdRake::RakeSupport.new
packer = RsdRake::PackerSupport.new
berkshelf = RsdRake::BerkshelfSupport.new

namespace 'packer' do
  desc 'Build packer container with template from template.json'
  task :build, :template do |t, args|
    puts ">>> Building packer template file."

      # Load cookbooks to correct dir.
      puts ">>>> Vendoring cookbooks with berks to #{berks_dir}"
      berkshelf.berks_vendor()

      puts ">>>> Packer using template: #{args[:template]}"

      # Run packer
      packer.packer_build(args[:template], berkshelf.berkshelf_dir)

      berkshelf.berks_cleanup()
  end
end

namespace 'kch' do
  desc 'Run kitchen converge for given suite'
  task :cn, :suite do |t, args|
    system("kitchen converge #{args[:suite]}")
  end

  desc 'Run kitchen verify for given suite'
  task :vr, :suite do |t, args|
    system("kitchen verify #{args[:suite]}")
  end

  desc 'Run kitchen test for given platform'
  task :ts, :suite do |t, args|
    system("kitchen test #{args[:suite]}")
  end
end

task :default do
  system("rake -T")
end
