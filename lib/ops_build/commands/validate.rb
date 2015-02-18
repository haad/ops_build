module OpsBuild
  module Commands
    class Validate < Thor
      desc 'packer TEMPLATE', 'validate packer template'
      def packer(template)
        packer = OpsBuild::Packer.new
        packer.validate(template)
      end
    end
  end
end