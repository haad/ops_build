require 'rubygems'

require 'fileutils'
require 'json'
require 'rbconfig'
require 'tempfile'
require 'thor'
require 'yaml'

lib = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "ops_build/version"
require 'ops_build/aws'
require 'ops_build/berkshelf'
require 'ops_build/chefspec'
require 'ops_build/kitchen'
require 'ops_build/packer'
require 'ops_build/vagrant'

class OpsBuilder < Thor
  class_option :verbose, :type => :boolean

  desc 'validate template', 'validate packer template'
  def validate_packer(template)
    packer = OpsBuild::PackerSupport.new
    packer.packer_validate(template)
  end

  desc 'build template', 'build packer template'
  option :ec2_region, :type => :string, :aliases => 'R', :desc => 'AWS EC2 region'
  option :aws_access, :type => :string, :aliases => 'A', :desc => 'AWS Access key'
  option :aws_secret, :type => :string, :aliases => 'S', :desc => 'AWS Secret key'
  option :berk_dir,   :type => :string, :aliases => 'b', :desc => 'Berkshelf cookbook directory path'
  def build_packer(template)
    packer = OpsBuild::PackerSupport.new
    berkshelf = OpsBuild::BerkshelfSupport.new
    aws = OpsBuild::AwsSupport.new

    puts ">> Building VM using packer from template #{template}"

    # Add some config variables
    packer.packer_add_user_variable(:aws_access_key, options[:aws_access].nil? ? aws.aws_get_access_key : options[:aws_access])
    packer.packer_add_user_variable(:aws_secret_key, options[:aws_secret].nil? ? aws.aws_get_secret_key : options[:aws_secret])
    packer.packer_add_user_variable(:aws_region, options[:ec2_region].nil? ? aws.aws_get_ec2_region : options[:ec2_region])
    packer.packer_add_user_variable(:cookbook_path, berkshelf.berkshelf_dir)

    # Install missing cookbooks
    berkshelf.berks_install()

    # Load cookbooks to correct dir.
    berkshelf.berks_vendor()

    begin
      # Validate packer template
      packer.packer_validate(template)
    rescue
      berkshelf.berks_cleanup()
      packer.packer_cleanup()
      exit(1)
    end
    puts ">>>> Vendoring cookbooks with berks to #{berkshelf.berkshelf_dir}"

    begin
      # Run packer
      packer.packer_build(template)
    rescue
      berkshelf.berks_cleanup()
      packer.packer_cleanup()
      exit(1)
    end

    packer.packer_get_ami_id()

    puts ">>>> Cleaning up cookbooks/packer files from system."
    berkshelf.berks_cleanup()
    packer.packer_cleanup()
  end

  desc 'cnv suite', 'Run kitchen converge for given suite'
  def converge_kitchen(suite)
    kitchen = OpsBuild::KitchenSupport.new
    kitchen.kitchen_converge(suite)
  end

  desc 'vrf suite', 'Run kitchen verify for given suite'
  def verify_kitchen(suite)
    kitchen = OpsBuild::KitchenSupport.new
    kitchen.kitchen_verify(suite)
  end

  desc 'tst suite', 'Run kitchen test for given platform'
  def test_kitchen(suite)
    kitchen = OpsBuild::KitchenSupport.new
    kitchen.kitchen_test(suite)
  end
end
