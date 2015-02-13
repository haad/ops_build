#
# Packer management class
#
module OpsBuild
  class Packer
    attr_accessor :user_vars, :user_var_file, :packer_log

    def initialize
      @user_vars = {}

      unless system("packer version 1>/dev/null")
        puts(">>> Packer not installed !")
        exit(1)
      end
    end

    #
    # Add name/value pair to users_vars hash which is going to be used later for packer var-file
    def packer_add_user_variable(name, value)
      unless name.nil? and value.nil?
        @user_vars[name] = value
      end
    end

    #
    # Run packer build
    def packer_build(packer_config)
      packer_options = ""

      packer_create_var_file

      unless @user_var_file.nil?
        puts(">>>> Changing packer build with variables file from: #{@user_var_file.path} ")
        packer_options = "-machine-readable -var-file #{@user_var_file.path}"
      end

      if @packer_log.nil?
        packer_create_log_file
        puts(">>>> Using file #{@packer_log.path} as log file.")
      end

      unless system("packer build #{packer_options} #{packer_config} | tee -a #{@packer_log.path}")
        puts(">>>> Packer build failed.")
        raise
      end
      puts(">>>>> packer run exit $?")
    end

    def packer_get_ami_id
      # Get AMI id by greping log for given string and then getting last value
      ami = File.foreach(@packer_log.path).grep(/amazon-ebs,artifact.*,id/).first

      if ami.nil?
        puts(">>>> Packer build failed.")
        exit(1)
      else
        puts(">>>> Packer built ami: #{ami}")
        ami.chomp.split(':').last
      end
    end

    #
    # Validate packer template
    def packer_validate(packer_config)
      packer_options = ""

      packer_create_var_file

      unless @user_var_file.nil?
        puts(">>>> Customizing packer build with variable file from: #{@user_var_file.path} ")
        packer_options = "-var-file #{@user_var_file.path}"
      end

      unless system("packer validate #{packer_options} #{packer_config}")
        puts(">>> Packer template validation failed !")
        raise
      end
    end

    #
    # Clean user_var-file/packer_log from system
    def packer_cleanup
      unless @user_var_file.nil?
        @user_var_file.unlink
        @user_var_file.close
      end

      unless @packer_log.nil?
        @packer_log.unlink
        @packer_log.close
      end
    end

    private
    def packer_create_log_file
      if @packer_log.nil?
        @packer_log = Tempfile.new('packer-log-file')
      end
    end

    def packer_create_var_file
      if @user_var_file.nil?
        @user_var_file = Tempfile.new('packer-var-file')
        @user_var_file.write(@user_vars.to_json)
        @user_var_file.rewind
      end
    end
  end
end
