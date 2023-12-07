# frozen_string_literal: true

require 'securerandom'

class AwsS3Service
  def get_object(params)
    client_credentials = Aws::Credentials.new(ENV.fetch('AWS_ACCESS_KEY_ID'), ENV.fetch('AWS_SECRET_ACCESS_KEY'))
    options = {
      region: ENV.fetch('AWS_DEFAULT_REGION'),
      credentials: client_credentials
    }

    s3 = Aws::S3::Client.new
    response = s3.get_object(bucket: params[:bucket], key: params[:key])
    response
  end
end
