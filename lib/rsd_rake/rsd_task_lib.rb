#
# Generic management class
#
module RsdRake
  class AwsSupport
    def aws_get_account_id
      ENV['AWS_ACCOUNT_ID']
    end

    def aws_get_access_key
      ENV['AWS_ACCESS_KEY']
    end

    def aws_get_secret_key
      ENV['AWS_SECRET_KEY']
    end
  end
  class RakeSupport

  end
end
