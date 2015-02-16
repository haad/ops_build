module OpsBuild
  class Validations
    def self.not_empty!(val, var_name)
      raise "'#{var_name}' cannot be empty!" if val.nil? || val.empty?
    end

    def self.check_binary!(bin)
      raise "Binary '#{bin}' not found!" if `command -v #{bin}`.empty?
    end
  end
end