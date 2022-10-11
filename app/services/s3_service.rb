# frozen_string_literal: true
require 'securerandom'

class S3Service
  def initialize
    @s3Client = self.s3_client
  end

  def presigned_url(params)
    s3 = Aws::S3::Resource.new(client: @s3Client)
    bucket = s3.bucket(Figaro.env.s3_logo_bucket_name)
    obj = bucket.object("original/#{SecureRandom.uuid}/#{params[:fileName]}")

    obj.presigned_post(acl: "public-read", content_type: params[:fileType])
  end

  private

  def s3_client
    credentials = Aws::Credentials.new(Figaro.env.s3_access_key_id, Figaro.env.s3_secret_access_key)
    options = {
      region: Figaro.env.aws_region,
      credentials: credentials
    }

    client = Aws::STS::Client.new(options)

    role_credentials = Aws::AssumeRoleCredentials.new(
        client: client,
        role_arn: Figaro.env.s3_role_arn,
        role_session_name: Figaro.env.s3_role_session_name
    )

    @s3Client = Aws::S3::Client.new(region: Figaro.env.aws_region, credentials: role_credentials)
  end
end
