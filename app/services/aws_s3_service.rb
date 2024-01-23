# frozen_string_literal: true

class AwsS3Service
  def get_object(params)
    credentials = Aws::ECSCredentials.new
    options = {
      region: ENV.fetch('AWS_REGION'),
      credentials: credentials
    }
    s3 = Aws::S3::Client.new(options)
    response = s3.get_object(bucket: params[:bucket], key: params[:key])

    response.body.read
  end
end
