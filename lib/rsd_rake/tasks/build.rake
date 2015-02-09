require 'rubygems'
require 'rake'
require 'yaml'
require 'json'
require 'tempfile'
require 'rbconfig'
require 'fileutils'

require 'erubis'

require 'chef/cookbook/metadata'

namespace 'packer' do
  packer = RsdRake::PackerSupport.new
  berkshelf = RsdRake::BerkshelfSupport.new

  desc 'Build packer container with template from template.json'
  task :build, :template do |t, args|
    puts ">>> Packer using template: #{args[:template]}"

    # Load cookbooks to correct dir.
    puts ">>>> Vendoring cookbooks with berks to #{berks_dir}"
    berkshelf.berks_vendor()

    packer.packer_add_user_variable(:aws_access_key, 'access')
    packer.packer_add_user_variable(:aws_secret_key, 'secret')
    packer.packer_add_user_variable(:cookbook_path, berkshelf.berkshelf_dir)

    # Run packer
    packer.packer_build(args[:template])

    puts ">>>> Cleaning up cookbooks/packer files from system."
    berkshelf.berks_cleanup()
    packer.packer_cleanup()
  end
end

namespace 'kch' do
  kitchen = RsdRake::KitchenSupport.new

  desc 'Run kitchen converge for given suite'
  task :cnv, :suite do |t, args|
    kitchen.kitchen_converge(args[:suite])
  end

  desc 'Run kitchen verify for given suite'
  task :vrf, :suite do |t, args|
    kitchen.kitchen_verify(args[:suite])
  end

  desc 'Run kitchen test for given platform'
  task :tst, :suite do |t, args|
    kitchen.kitchen_test(args[:suite])
  end
end

task :default do
  system("rake -T")
end
