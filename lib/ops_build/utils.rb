module OpsBuild
  class Utils
    def self.execute(cmd, log_level: :debug, log_prefix: '', raise_on_failure: true, env: nil)
      log_prefix << " " unless log_prefix.end_with?(" ")
      OpsBuild.logger.debug("Running command '#{cmd}'")
      args = [cmd]
      args.unshift(env) if env
      _, out, wait_thr = Open3.popen2e(*args)

      while line = out.gets
        OpsBuild.logger.__send__(log_level, "#{log_prefix}#{line}")
      end

      code = wait_thr.value.exitstatus # #value is blocking call
      raise "Error executing '#{cmd}'. Exit code: #{code}" if code != 0 && raise_on_failure
      out.close

      code
    end
  end
end