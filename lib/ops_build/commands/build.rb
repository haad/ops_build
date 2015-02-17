module OpsBuild
  module Commands
    class Build < Thor
      def self.shared_options
        option :ec2_region, type: :string, aliases: '-R', desc: 'AWS EC2 region', default: 'us-east-1'
        option :aws_access, type: :string, aliases: '-A', desc: 'AWS Access key'
        option :aws_secret, type: :string, aliases: '-S', desc: 'AWS Secret key'
        option :params,     type: :string, aliases: '-p', desc: 'path to JSON as params'
      end

      desc 'packer TEMPLATE', 'build packer template'
      shared_options
      option :berk_dir,   type: :string, aliases: '-b', desc: 'Berkshelf cookbook directory path'
      def packer(template)
        packer = Packer.new
        berkshelf = Berkshelf.new(dir: options[:berk_dir], silent: false)
        # aws = Aws.new

        raise "JSON #{options[:params]} not found!" unless File.exists?(options[:params])
        params = JSON.parse(File.read(options[:params]), symbolize_names: true)

        OpsBuild.logger.info("Building VM using packer from template #{template}")

        # aws_access_key = options[:aws_access] || aws.aws_get_access_key
        # aws_secret_key = options[:aws_secret] || aws.aws_get_secret_key
        # aws_region = options[:ec2_region] || aws.aws_get_ec2_region

        aws_access_key = options[:aws_access] || ENV['AWS_ACCESS_KEY']
        aws_secret_key = options[:aws_secret] || ENV['AWS_SECRET_KEY']
        aws_region     = options[:ec2_region] || ENV['AWS_EC2_REGION']

        # Validations::not_empty!(aws_access_key, :aws_access)
        # Validations::not_empty!(aws_secret_key, :aws_secret)
        # Validations::not_empty!(aws_region, :ec2_region)

        # Add some config variables
        packer.add_user_variable(:aws_access_key, aws_access_key) if aws_access_key
        packer.add_user_variable(:aws_secret_key, aws_secret_key) if aws_secret_key
        packer.add_user_variable(:aws_region, aws_region) if aws_region
        packer.add_user_variable(:cookbook_path, berkshelf.dir)
        params.each { |k, v| packer.add_user_variable(k, v) }

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

      desc 'vagrant TEMPLATE', 'build vagrant box'
      shared_options
      def vagrant(template)
        # TODO
      end
    end
  end
end