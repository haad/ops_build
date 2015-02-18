module OpsBuild
  class Runner < Thor
    class_option :verbose, type: :boolean, default: false

    #
    # Adjust global options
    def initialize(*args, &block)
      super(*args, &block)
      OpsBuild.logger.level = Logger::DEBUG if options[:verbose]
    end

    desc 'build SUBCOMMAND ...ARGS', 'build'
    subcommand 'build', Commands::Build

    desc 'validate SUBCOMMAND ...ARGS', 'validate'
    subcommand 'validate', Commands::Validate

    desc 'kitchen SUBCOMMAND ...ARGS', 'kitchen'
    subcommand 'kitchen', Commands::Kitchen

    desc 'index', 'index vagrant box folder and write json'
    option :directory, type: :string, aliases: '-d', required: true, desc: 'Directory to search vagrant boxes in, e.g. \'/var/www/centos65/boxes\''
    option :json_path, type: :string, aliases: '-j', required: true, desc: 'Path to output json, e.g. \'/var/www/centos65/centos.json\''
    option :name,      type: :string, aliases: '-n', required: true, desc: 'Box name, e.g. \'centos65\''
    option :desc,      type: :string, aliases: '-e', required: true, desc: 'Description of box collection, e.g. \'This box contains CentOS 6.5 build XYZ 64-bit\''
    option :root_url,  type: :string, aliases: '-r', required: true, desc: 'Root URL of boxes, e.g. \'http://example.com/centos65/boxes\''
    def index
      BoxIndexer.new(dir:      options[:directory],
                     out:      options[:json_path],
                     name:     options[:name],
                     desc:     options[:desc],
                     root_url: options[:root_url]).index!
    rescue => e
      OpsBuild.logger.error(e.message)
      exit(1)
    end
  end
end