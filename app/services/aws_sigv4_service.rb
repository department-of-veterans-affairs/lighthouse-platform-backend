# frozen_string_literal: true

require 'securerandom'

class AwsSigv4Service
  def initialize
    @source_folder = 'original/'
    @role_access_key_id = Figaro.env.s3_access_key_id
    @role_secret_access_key = Figaro.env.s3_secret_access_key
    @bucket = Figaro.env.s3_logo_bucket_name
    @role_session_token = ''
    @key = ''
    @content_type = ''
    credentials
  end

  def set_key(key)
    @key = key
  end

  def set_content_type(content_type)
    @content_type = content_type
  end

  # rubocop:disable Metrics/MethodLength
  def sign_request
    # Construct variable that will be used
    s3_region = Figaro.env.aws_region
    acl = 'public-read'

    current_dt = DateTime.now
    policy_date = current_dt.utc.strftime('%Y%m%d')
    x_amz_date = current_dt.utc.strftime('%Y%m%dT%H%M%SZ')

    x_amz_algorithm = 'AWS4-HMAC-SHA256'
    x_amz_credential = "#{@role_access_key_id}/#{policy_date}/#{s3_region}/s3/aws4_request"

    encoded_policy = get_encoded_policy_document(
      "#{@source_folder}#{@key}",
      acl,
      x_amz_algorithm,
      x_amz_credential,
      x_amz_date
    )
    x_amz_signature = get_signature(policy_date, s3_region, encoded_policy)

    {
      acl: acl,
      bucket_name: @bucket,
      content_type: @content_type,
      key: "#{@source_folder}#{@key}",
      logoUrls: [
        "https://#{@bucket}.s3.#{s3_region}.amazonaws.com/40x40/#{@key}",
        "https://#{@bucket}.s3.#{s3_region}.amazonaws.com/1024x1024/#{@key}"
      ],
      policy: encoded_policy,
      resizeTriggerUrls: [
        "http://#{@bucket}.s3-website-#{s3_region}.amazonaws.com/40x40/#{@key}",
        "http://#{@bucket}.s3-website-#{s3_region}.amazonaws.com/1024x1024/#{@key}"
      ],
      s3_region_endpoint: "s3.#{s3_region}.amazonaws.com",
      x_amz_algorithm: x_amz_algorithm,
      x_amz_credential: x_amz_credential,
      x_amz_date: x_amz_date,
      x_amz_expires: 900,
      x_amz_security_token: @role_session_token,
      x_amz_signature: x_amz_signature
    }
  end

  private

  def credentials
    client_credentials = Aws::Credentials.new(Figaro.env.s3_access_key_id, Figaro.env.s3_secret_access_key)
    options = {
      region: Figaro.env.aws_region,
      credentials: client_credentials
    }

    client = Aws::STS::Client.new(options)

    resp = client.assume_role({
                                role_arn: Figaro.env.s3_role_arn,
                                role_session_name: Figaro.env.s3_role_session_name
                              })

    @role_access_key_id = resp.to_h[:credentials][:access_key_id]
    @role_secret_access_key = resp.to_h[:credentials][:secret_access_key]
    @role_session_token = resp.to_h[:credentials][:session_token]

    resp.to_h
  end

  def get_encoded_policy_document(source_key, acl, x_amz_algorithm, x_amz_credential, x_amz_date)
    Base64.encode64(
      {
        'expiration' => 15.minutes.from_now.utc.xmlschema,
        'conditions' => [
          { 'bucket' => @bucket },
          ['eq', '$key', source_key],
          { 'acl' => acl },
          ['eq', '$Content-Type', @content_type],
          { 'x-amz-algorithm' => x_amz_algorithm },
          { 'x-amz-credential' => x_amz_credential },
          { 'x-amz-date' => x_amz_date },
          { 'x-amz-security-token' => @role_session_token }
        ]
      }.to_json
    ).gsub("\n", '')
  end
  # rubocop:enable Metrics/MethodLength

  def get_signature_key(date_stamp, region_name, service_name)
    k_date = OpenSSL::HMAC.digest('sha256', "AWS4#{@role_secret_access_key}", date_stamp)
    k_region = OpenSSL::HMAC.digest('sha256', k_date, region_name)
    k_service = OpenSSL::HMAC.digest('sha256', k_region, service_name)
    OpenSSL::HMAC.digest('sha256', k_service, 'aws4_request')
  end

  def get_signature(policy_date, s3_region, encoded_policy)
    signature_key = get_signature_key(policy_date, s3_region, 's3')

    OpenSSL::HMAC.hexdigest('sha256', signature_key, encoded_policy)
  end
end
