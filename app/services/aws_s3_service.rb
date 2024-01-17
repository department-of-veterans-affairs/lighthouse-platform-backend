# frozen_string_literal: true

require 'securerandom'

class AwsS3Service
  def get_object(params)
    if Rails.env === 'development'
      # Because of access restrictions to the s3 bucket with the users file we need to fake
      # the request when doing local dev through a basic, unauthenticated GET request.
      url = "https://#{params[:bucket]}.s3.#{ENV.fetch('AWS_DEFAULT_REGION')}.amazonaws.com/#{params[:key]}"
      uri = URI.parse(url)
      res = Net::HTTP.get_response(uri)

      res.body
    else
      credentials = Aws::ECSCredentials.new
      options = {
        region: ENV.fetch('AWS_DEFAULT_REGION'),
        credentials: credentials
      }
      s3 = Aws::S3::Client.new(options)
      response = s3.get_object(bucket: params[:bucket], key: params[:key])

      response.body.read
    end
  end
end
