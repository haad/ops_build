
module RsdRake
  class RakeSupport
    attr_accessor :kitchen_file, :packer_file, :metadata_file

    def initialize
      @kitchen_file=".kitchen.yml"
      @packer_file=File.expand_path('../templates/template.json.erb', __FILE__)
      @metadata_file="metadata.rb"
    end

    #
    # Run packer
    def execute_packer(packer_config)
      system("packer build #{packer_config}")
    end

    #
    # Before we can start container, we need to check if his name doesn't exist
    def dock_cont_rm(cont_name)
      self.dock_cont_stop
      system("docker ps -a | grep -qw #{cont_name}")
      if $?.exitcode
        system("docker rm #{cont_name}")
      end
    end

    #
    # Stop running docker container
    def dock_cont_stop(cont_name)
      system("docker ps | grep -qw #{cont_name}")
      if $?.exitcode
        system("docker stop #{cont_name}")
      end
    end

    #
    # Run berks
    def execute_berks(berks_dir)
      system("berks vendor #{berks_dir}")
    end

    def get_metadata_version()
      metadata = Chef::Cookbook::Metadata.new
      metadata.from_file(@metadata_file)

      metadata.version
    end

    def get_metadata_name()
      metadata = Chef::Cookbook::Metadata.new
      metadata.from_file(@metadata_file)

      metadata.name
    end
  end
end
