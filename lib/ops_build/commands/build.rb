module OpsBuild
  module Commands
    class Build < Thor
      desc 'packer TEMPLATE', 'build packer template'
      option :ec2_region, :type => :string, :aliases => 'R', :desc => 'AWS EC2 region'
      option :aws_access, :type => :string, :aliases => 'A', :desc => 'AWS Access key'
      option :aws_secret, :type => :string, :aliases => 'S', :desc => 'AWS Secret key'
      option :berk_dir,   :type => :string, :aliases => 'b', :desc => 'Berkshelf cookbook directory path'
      def packer(template)
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
        berkshelf.berks_install

        # Load cookbooks to correct dir.
        berkshelf.berks_vendor

        begin
          # Validate packer template
          packer.packer_validate(template)
        rescue
          berkshelf.berks_cleanup
          packer.packer_cleanup
          exit(1)
        end
        puts ">>>> Vendoring cookbooks with berks to #{berkshelf.berkshelf_dir}"

        begin
          # Run packer
          packer.packer_build(template)
        rescue
          berkshelf.berks_cleanup
          packer.packer_cleanup
          exit(1)
        end

        packer.packer_get_ami_id

        puts ">>>> Cleaning up cookbooks/packer files from system."
        berkshelf.berks_cleanup
        packer.packer_cleanup
      end

      desc 'vagrant TEMPLATE', 'build vagrant template'
      def vagrant(template)
        # TODO
      end
    end
  end
end