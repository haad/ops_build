#
# Kitchen test management class
#
module OpsBuild
  class Kitchen
    def kitchen_converge(suite)
      system("kitchen converge #{suite}")
    end

    def kitchen_verify(suite)
      system("kitchen verify #{suite}")
    end

    def kitchen_test(suite)
      system("kitchen test #{suite}")
    end
  end
end
