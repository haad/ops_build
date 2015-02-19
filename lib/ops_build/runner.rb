module OpsBuild
  class Runner < Thor
    class_option :verbose, type: :boolean, default: false

    def self.exit_on_failure?
      true
    end

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

    desc 'generate SUBCOMMAND ...ARGS', 'generate'
    subcommand 'generate', Commands::Generate
  end
end