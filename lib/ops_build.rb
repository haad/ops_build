require 'rubygems'

require 'fileutils'
require 'json'
require 'rbconfig'
require 'tempfile'
require 'thor'
require 'yaml'

require "ops_build/version"
require 'ops_build/aws'
require 'ops_build/berkshelf'
require 'ops_build/chefspec'
require 'ops_build/kitchen'
require 'ops_build/packer'
require 'ops_build/vagrant'

lib = File.expand_path('.', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

class OpsBuilder < Thor
  desc 'validate template', 'validate packer template'
  def validate_packer(template)
    packer = OpsBuild::PackerSupport.new
    packer.packer_validate(template)
  end

  desc 'build template', 'build packer template'
  def build_packer(template)
    packer = OpsBuild::PackerSupport.new
    berkshelf = OpsBuild::BerkshelfSupport.new
    aws = OpsBuild::AwsSupport.new

    puts ">> Building VM using packer from template #{template}"

    # Add some config variables
    packer.packer_add_user_variable(:aws_account_id, aws.aws_get_account_id)
    packer.packer_add_user_variable(:aws_access_key, aws.aws_get_access_key)
    packer.packer_add_user_variable(:aws_secret_key, aws.aws_get_secret_key)
    packer.packer_add_user_variable(:cookbook_path, berkshelf.berkshelf_dir)

    # Validate packer template
    packer.packer_validate(template)

    # Install missing cookbooks
    berkshelf.berks_install()

    # Load cookbooks to correct dir.
    berkshelf.berks_vendor()
    puts ">>>> Vendoring cookbooks with berks to #{berkshelf.berkshelf_dir}"

    # Run packer
    packer.packer_build(template)

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
