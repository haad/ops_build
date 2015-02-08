#
# Packer management class
#
module RsdRake
  class PackerSupport

    def initialize()
      unless system("packer version")
        puts(">>> Packer not installed !")
        exit(1)
      end
    end

    #
    # Run packer build
    def packer_build(packer_config, berks_dir)
      system("packer build -V cookbook_path=#{berks_dir} #{packer_config}")
    end

    #
    # Validate packer template
    def packer_validate(packer_config)
      system("packer validate #{packer_config}")
    end
  end
end
