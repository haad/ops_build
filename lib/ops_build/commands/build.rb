module OpsBuild
  module Commands
    class Build < Thor
      desc 'packer TEMPLATE', 'build packer template'
      option :ec2_region, type: :string, aliases: '-R', desc: 'AWS EC2 region'
      option :aws_access, type: :string, aliases: '-A', desc: 'AWS Access key'
      option :aws_secret, type: :string, aliases: '-S', desc: 'AWS Secret key'
      option :berk_dir,   type: :string, aliases: '-b', desc: 'Berkshelf cookbook directory path'
      def packer(template)
        packer = Packer.new
        berkshelf = Berkshelf.new(dir: options[:berk_dir], silent: false)
        aws = Aws.new

        OpsBuild.logger.info("Building VM using packer from template #{template}")

        aws_access_key = options[:aws_access] || aws.aws_get_access_key
        aws_secret_key = options[:aws_secret] || aws.aws_get_secret_key
        aws_region = options[:ec2_region] || aws.aws_get_ec2_region

        Validations::not_empty!(aws_access_key, :aws_access)
        Validations::not_empty!(aws_secret_key, :aws_secret)
        Validations::not_empty!(aws_region, :ec2_region)

        # Add some config variables
        packer.add_user_variable(:aws_access_key, aws_access_key)
        packer.add_user_variable(:aws_secret_key, aws_secret_key)
        packer.add_user_variable(:aws_region, aws_region)
        packer.add_user_variable(:cookbook_path, berkshelf.dir)

        begin
          # Install missing cookbooks
          berkshelf.install

          # Load cookbooks to correct dir.
          berkshelf.vendor

          # Validate packer template
          packer.validate(template)

          # Run packer
          packer.build(template)

          packer.get_ami_id
        rescue => e
          OpsBuild.logger.error(e.message)
          exit(1)
        ensure
          OpsBuild.logger.info("Cleaning up cookbooks/packer files from system.")
          berkshelf.cleanup
          packer.cleanup
        end
      end

      desc 'vagrant TEMPLATE', 'build vagrant template'
      def vagrant(template)
        # TODO
      end
    end
  end
end