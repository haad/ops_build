#
# Packer management class
#
module RsdRake
  require 'json'
  require 'tempfile'

  class PackerSupport
    attr_accessor :user_vars, :user_var_file

    def initialize()
      @user_vars = {}

      unless system("packer version")
        puts(">>> Packer not installed !")
        exit(1)
      end
    end

    def packer_add_user_variable(name, value)
      unless name.nil? and value.nil?
        @user_vars[name] = value
      end
    end

    #
    # Run packer build
    def packer_build(packer_config)
      packer_options = ""

      packer_create_var_file()

      unless @user_var_file.nil?
        packer_options = "-var-file #{@user_var_file.path}"
      end

      system("packer build #{packer_options} #{packer_config}")
    end

    #
    # Validate packer template
    def packer_validate(packer_config)
      system("packer validate #{packer_config}")
    end

    #
    # Clean user_var-file from system
    def packer_cleanup()
      unless @user_var_file.nil?
        @user_var_file.unlink
        @user_var_file.close
      end
    end

    private: packer_create_var_file

    def packer_create_var_file()
      @user_var_file = Tempfile.new('packer-var-file')
      @user_var_file.write(@user_vars.to_json)
      @user_var_file.rewind
    end
  end
end
