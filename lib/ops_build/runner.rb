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
  end
end