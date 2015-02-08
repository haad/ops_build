#
# Berkshelf management class
#
module RsdRake
  class BerkshelfSupport
    attr_accessor :berkshelf_dir

    def initialize(berks_dir)
      unless system("berks version")
        puts(">>> Berks not installed !")
        exit(1)
      end

      if @berks_dir.empty?
        # Create temporary directory for packer/docker communication
        @berkshelf_dir = Dir::tmpdir+"/"+Dir::Tmpname.make_tmpname('berks', nil)
      else
        @berkshelf_dir = berks_dir
      end
    end

    #
    # Run berks vendor
    def berks_vendor()
      system("berks vendor #{@berkshelf_dir}")
    end

    #
    # Run berks install
    def berks_install
      system("berks install")
    end

    #
    # Cleanup Berks directory
    def berks_cleanup()
      FileUtils.rm_rf(@berkshelf_dir)
    end
  end
end
