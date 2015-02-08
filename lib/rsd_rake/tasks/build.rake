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

namespace 'packer' do
  desc 'Build packer container with template from template.json'
  task :build do
    puts ">>> Building packer template file."

    # Create temporary directory for packer/docker communication
    berks_dir = Dir::tmpdir+"/"+Dir::Tmpname.make_tmpname('berks', nil)

    if File.exists?(rsd_rake.kitchen_file) and File.exists?(rsd_rake.packer_file)
      # Load data from kitchen file
      kitchen = YAML.load_file(rsd_rake.kitchen_file)
      kitchen_attr = kitchen["suites"].first["attributes"]
      kitchen_run_list = kitchen["suites"].first["run_list"]

      # Read packer template
      temp = IO.read(rsd_rake.packer_file)
      temp = Erubis::Eruby.new(temp)

      # create Temp file for a packer build
      f = Tempfile.new(['template', '.json'])

      # Run template, get name and version from metadata.rb
      json = temp.result(:image_name => rsd_rake.get_metadata_name, :image_version => rsd_rake.get_metadata_version,
        :image_runlist => "#{kitchen_run_list}", :image_attributes => "#{kitchen_attr.to_json}", :cookbook_path => "#{berks_dir}")

      f << json
      puts ">>> Creating temporary packer template file at #{f.path}"
      f.close

      # Load cookbooks to correct dir.
      puts ">>> Vendoring cookbooks with berks to #{berks_dir}"
      rsd_rake.execute_berks(berks_dir)

      puts ">>>> Packer using this template:"
      puts json
      puts ">>>> >>>> >>>>"

      # Remove old container if there is any
      rsd_rake.doc_cont_rm(rsd_rake.get_metadata_name)

      # Run packer
      rsd_rake.execute_packer(f.path)

      FileUtils.rm(f.path)
      FileUtils.rm_rf(berks_dir)
      rsd_rake.doc_cont_stop(rsd_rake.get_metadata_name)
    else
      puts "I can't find #{kitchen_file} or #{packer_file} just running plain packer build"
      execute_packer("template.json")
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
