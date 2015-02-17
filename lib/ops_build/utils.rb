module OpsBuild
  class Utils
    def self.execute(cmd, log_level: :debug, log_prefix: '', raise_on_failure: true)
      OpsBuild.logger.debug("Running command '#{cmd}'")
      _, out, wait_thr = Open3.popen2e(cmd)

      while line = out.gets
        OpsBuild.logger.__send__(log_level, "#{log_prefix} #{line}")
      end

      code = wait_thr.value.exitstatus # #value is blocking call
      raise "Error executing '#{cmd}'. Exit code: #{code}" if code != 0 && raise_on_failure
      out.close

      code
    end
  end
end