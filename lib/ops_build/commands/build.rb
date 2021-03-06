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
      option :berk_dir, type: :string, aliases: '-b', desc: 'Berkshelf cookbook directory path'
      def packer(template)
        packer = Packer.new
        berkshelf = Berkshelf.new(dir: options[:berk_dir], silent: false)
        params = if options[:params]
                   raise "JSON #{options[:params]} not found!" unless File.exists?(options[:params])
                   JSON.parse(File.read(options[:params]), symbolize_names: true)
                 else
                   {}
                 end

        OpsBuild.logger.info("Building VM using packer from template #{template}")

        aws_access_key = options[:aws_access] || ENV['AWS_ACCESS_KEY']
        aws_secret_key = options[:aws_secret] || ENV['AWS_SECRET_KEY']
        aws_region     = options[:ec2_region] || ENV['AWS_EC2_REGION']

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
        rescue => e
          OpsBuild.logger.error(e.message)
          exit(1)
        ensure
          OpsBuild.logger.info("Cleaning up cookbooks/packer files from system.")
          berkshelf.cleanup
          packer.cleanup
        end
      end

      desc 'vagrant VAGRANTFILE', 'build vagrant box'
      shared_options
      option :only,   type: :string, aliases: '-l', desc: 'Do not create all boxes, just the one passed as argument'
      option :output, type: :string, aliases: '-o', desc: 'Name of the output (box)', default: 'package.box'
      def vagrant(path)
        path = File.expand_path(path)
        raise "Vagrantfile #{path} not found!" unless File.exists?(path)

        # TODO: parse jason params -> 'base_url'

        env = { 'VAGRANT_CWD' => File.dirname(path) }
        if options[:params]
         raise "JSON #{options[:params]} not found!" unless File.exists?(options[:params])
         JSON.parse(File.read(options[:params])).each do |k, v|
           env[k.to_s.upcase] = v
         end
        end

        OpsBuild.logger.info('Running vagrant up')
        Utils::execute(
            "vagrant up #{options[:only]}", # still correct even if --only not provided, because nil.to_s == ""
            log_prefix: 'vagrant:',
            env: env)

        uuid = SecureRandom.uuid
        OpsBuild.logger.info("Running vagrant ssh cmd 'info > /vagrant/#{uuid}'")
        Utils::execute(
        "vagrant ssh #{options[:only]} -c 'info > /vagrant/#{uuid}'",
        log_prefix: 'vagrant:',
        env: env)
        info_path = File.join(env['VAGRANT_CWD'], uuid)
        FileUtils.cp(info_path, "#{options[:output]}.metadata")

        OpsBuild.logger.info('Running vagrant package')
        Utils::execute(
            "vagrant package #{options[:only]} --output #{options[:output]}",
            log_prefix: 'vagrant:',
            env: env)
      ensure
        OpsBuild.logger.info('Running vagrant destroy')
        Utils::execute(
            'vagrant destroy -f',
            log_prefix: 'vagrant',
            env: env
        )
        # TODO: vboxmanage
      end
    end
  end
end
