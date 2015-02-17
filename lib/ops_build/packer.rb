#
# Packer management class
#
module OpsBuild
  class Packer
    attr_accessor :user_vars, :user_var_file

    def initialize
      Validations::check_binary!('packer')
      @user_vars = {}
    end

    #
    # Add name/value pair to users_vars hash which is going to be used later for packer var-file
    def add_user_variable(name, value)
      unless name.nil? and value.nil?
        @user_vars[name] = value
      end
    end

    #
    # Run packer build
    def build(config)
      options = ''

      create_var_file

      unless @user_var_file.nil?
        OpsBuild.logger.info("Changing packer build with variables file from: #{@user_var_file.path}")
        options = " -var-file #{@user_var_file.path}"
      end

      Utils::execute("packer build -color=false -machine-readable #{options} #{config}")
    end

    #
    # Validate packer template
    def validate(config)
      options = ''

      create_var_file

      unless @user_var_file.nil?
        OpsBuild.logger.info("Customizing packer build with variable file from: #{@user_var_file.path}")
        options = "-var-file #{@user_var_file.path}"
      end

      Utils::execute("packer validate #{options} #{config}")
    end

    #
    # Clean user_var-file/log from system
    def cleanup
      unless @user_var_file.nil?
        @user_var_file.unlink
        @user_var_file.close
      end
    end

    private
    def create_var_file
      if @user_var_file.nil?
        @user_var_file = Tempfile.new('packer-var-file')
        @user_var_file.write(@user_vars.to_json)
        @user_var_file.rewind
      end
    end
  end
end
