require 'rubygems'
require 'rake'
require 'yaml'
require 'json'
require 'tempfile'
require 'rbconfig'

require 'erubis'

require 'chef/cookbook/metadata'

kitchen_file="./.kitchen.yml"
packer_file=".packer/template.json.erb"
metadata_file="metadata.rb"

def os
  @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
    end
  )
end

def execute_packer(packer_config, packer_dir)
  system("packer build #{packer_config}")
end

def execute_berks(berks_dir)
  system("berks vendor #{berks_dir}")
end

def mount_sshfs(sshfs_dir)
  puts "mounting sshfs to #{sshfs_dir}"
  #system("sshfs root@docker-kitchen:#{sshfs_dir} #{sshfs_dir}")
end

def get_metadata_version(file)
  metadata = Chef::Cookbook::Metadata.new
  metadata.from_file(file)

  metadata.version
end

def get_metadata_name(file)
  metadata = Chef::Cookbook::Metadata.new
  metadata.from_file(file)

  metadata.name
end

namespace 'packer' do
  desc 'Build packer container with template from template.json'
  task :build do
    puts ">>> Building packer template file."

    # Create temporary directory for packer/docker communication
    packer_dir = Dir.mktmpdir("packer")
    berks_dir = Dir.mktmpdir("berks")

    if File.exists?(kitchen_file) and File.exists?(packer_file)
      # Load data from kitchen file
      kitchen = YAML.load_file(kitchen_file)
      kitchen_attr = kitchen["suites"].first["attributes"]
      kitchen_run_list = kitchen["suites"].first["run_list"]

      # Read packer template
      temp = IO.read(packer_file)
      temp = Erubis::Eruby.new(temp)

      # create Temp file for a packer build
      f = Tempfile.new(['template', '.json'])

      # Run template, get name and version from metadata.rb
      json = temp.result(:image_name => "#{get_metadata_name(metadata_file)}", :image_version => "#{get_metadata_version(metadata_file)}",
        :image_runlist => "#{kitchen_run_list}", :image_attributes => "#{kitchen_attr.to_json}", :cookbook_path => "#{berks_dir}")

      f << json
      puts ">>> Creating temporary packer template file at #{f.path}"
      f.close

      if os == :macosx and system("which sshfs")
        puts ">>>> Will try  to mount filesystem with sshfs from docker-kitchen to #{packer_dir}"
        mount_sshfs(packer_dir)
      end

      # Load cookbooks to correct dir.
      execute_berks(berks_dir)

      # Run packer
      execute_packer(f.path, packer_dir)

      Fileutils.rm(f.path)
      Fileutils.rm_rf(packer_dir)
      Fileutils.rm_rf(berks_dir)
    else
      puts "I can't find #{kitchen_file} or #{packer_file} just running plain packer build"
      execute_packer(packer_file, packer_dir)
    end
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
