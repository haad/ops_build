#
# Berkshelf management class
#
module OpsBuild
  class Berkshelf
    attr_reader :dir, :opts

    def initialize(dir: nil, silent: true)
      Validations::check_binary!('berks')

      @dir = dir || Dir.mktmpdir('berks')
      @opts = ''

      @opts << '-q' if silent
    end

    #
    # Run berks vendor
    def vendor
      OpsBuild.logger.info("Vendoring cookbooks with berks to #{@dir}")
      Utils::execute("berks vendor #{@opts} #{@dir}", log_prefix: 'berks:')
    end

    #
    # Run berks install
    def install
      OpsBuild.logger.info('Installing cookbooks with berks')
      Utils::execute("berks install #{@opts}", log_prefix: 'berks:')
    end

    #
    # Cleanup Berks directory
    def cleanup
      FileUtils.rm_rf(@dir)
    end
  end
end
