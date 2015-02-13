module OpsBuild
  module Commands
    class Kitchen < Thor
      desc 'coverage SUITE', 'Run kitchen converge for given suite'
      def converge_kitchen(suite)
        kitchen = OpsBuild::Kitchen.new
        kitchen.kitchen_converge(suite)
      end

      desc 'verify SUITE', 'Run kitchen verify for given suite'
      def verify_kitchen(suite)
        kitchen = OpsBuild::Kitchen.new
        kitchen.kitchen_verify(suite)
      end

      desc 'test SUITE', 'Run kitchen test for given platform'
      def test_kitchen(suite)
        kitchen = OpsBuild::Kitchen.new
        kitchen.kitchen_test(suite)
      end
    end
  end
end