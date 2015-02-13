module OpsBuild
  module Commands
    class Validate < Thor
      desc 'packer TEMPLATE', 'validate packer template'
      def packer(template)
        packer = OpsBuild::PackerSupport.new
        packer.packer_validate(template)
      end
    end
  end
end