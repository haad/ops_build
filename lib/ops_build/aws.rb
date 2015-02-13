#
# AWS management class
#
module OpsBuild
  class Aws
    def aws_get_account_id
      ENV['AWS_ACCOUNT_ID']
    end

    def aws_get_access_key
      ENV['AWS_ACCESS_KEY']
    end

    def aws_get_secret_key
      ENV['AWS_SECRET_KEY']
    end

    def aws_get_ec2_region
      ENV['AWS_EC2_REGION'] ? ENV['AWS_EC2_REGION'] : 'us-east-1'
    end
  end
end
