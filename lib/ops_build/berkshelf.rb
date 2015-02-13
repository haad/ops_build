#
# Berkshelf management class
#
module OpsBuild
  class BerkshelfSupport
    attr_accessor :berkshelf_dir, :berkshelf_opts

    def initialize(berks_dir = nil, silent = true)
      unless system("berks version -q")
        puts(">>> Berks not installed !")
        exit(1)
      end

      if @berks_dir.nil?
        # Create temporary directory for packer/docker communication
        @berkshelf_dir = Dir::tmpdir + "/" + Dir::Tmpname.make_tmpname('berks', nil)
      else
        @berkshelf_dir = berks_dir
      end

      if silent
        @berkshelf_opts = '-q'
      else
        @berkshelf_opts = ''
      end
    end

    #
    # Run berks vendor
    def berks_vendor
      system("berks vendor #{@berkshelf_opts} #{@berkshelf_dir}")
    end

    #
    # Run berks install
    def berks_install
      system("berks install #{@berkshelf_opts}")
    end

    #
    # Cleanup Berks directory
    def berks_cleanup
      FileUtils.rm_rf(@berkshelf_dir)
    end
  end
end
