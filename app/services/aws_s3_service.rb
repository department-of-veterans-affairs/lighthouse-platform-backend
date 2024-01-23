# frozen_string_literal: true

class AwsS3Service
  def get_object(params)
    options = {
      region: ENV.fetch('AWS_REGION'),
    }
    s3 = Aws::S3::Client.new(options)
    response = s3.get_object(bucket: params[:bucket], key: params[:key])

    response.body.read
  end
end
