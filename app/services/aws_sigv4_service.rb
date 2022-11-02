# frozen_string_literal: true
require 'securerandom'

class AwsSigv4Service
  def initialize
    @sourceFolder = 'original/'
    @roleAccessKeyId = Figaro.env.s3_access_key_id
    @roleSecretAccessKey = Figaro.env.s3_secret_access_key
    @roleSessionToken = ''
    self.credentials
  end
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

    @roleAccessKeyId = resp.to_h[:credentials][:access_key_id]
    @roleSecretAccessKey = resp.to_h[:credentials][:secret_access_key]
    @roleSessionToken = resp.to_h[:credentials][:session_token]

    resp.to_h
  end

  def get_policy
    @policy
  end

  def sign_request(params)
    
    # Construct variable that will be used
    s3_region =  Figaro.env.aws_region
    bucket = Figaro.env.s3_logo_bucket_name
    acl = 'public-read'
    
    current_dt = DateTime.now
    policy_date = current_dt.utc.strftime("%Y%m%d")
    x_amz_date = current_dt.utc.strftime("%Y%m%dT%H%M%SZ")

    x_amz_algorithm = "AWS4-HMAC-SHA256"
    x_amz_credential = "#{@roleAccessKeyId}/#{policy_date}/#{s3_region}/s3/aws4_request"    
    
    encoded_policy = get_encoded_policy_document(
      "#{@sourceFolder}#{params[:key]}",
      params[:contentType],
      bucket,
      acl,
      x_amz_algorithm,
      x_amz_credential,
      x_amz_date
    )
    x_amz_signature = get_signature( policy_date, s3_region, encoded_policy )
    
    {
      acl: acl,
      bucket_name: bucket,
      content_type: params[:contentType],
      key: "#{@sourceFolder}#{params[:key]}",
      logoUrls: [
        "https://#{bucket}.s3.#{s3_region}.amazonaws.com/40x40/#{params[:key]}",
        "https://#{bucket}.s3.#{s3_region}.amazonaws.com/1024x1024/#{params[:key]}",
      ],
      policy: encoded_policy,
      resizeTriggerUrls: [
        "http://#{bucket}.s3-website-#{s3_region}.amazonaws.com/40x40/#{params[:key]}",
        "http://#{bucket}.s3-website-#{s3_region}.amazonaws.com/1024x1024/#{params[:key]}",
      ],
      s3_region_endpoint: "s3.#{s3_region}.amazonaws.com",
      x_amz_algorithm: x_amz_algorithm,
      x_amz_credential: x_amz_credential,
      x_amz_date: x_amz_date,
      x_amz_expires: 900,
      x_amz_security_token: @roleSessionToken,
      x_amz_signature: x_amz_signature,
    }
  end

  private

  def get_signature_key( key, date_stamp, region_name, service_name )
      k_date = OpenSSL::HMAC.digest('sha256', "AWS4" + key, date_stamp)
      k_region = OpenSSL::HMAC.digest('sha256', k_date, region_name)
      k_service = OpenSSL::HMAC.digest('sha256', k_region, service_name)
      k_signing = OpenSSL::HMAC.digest('sha256', k_service, "aws4_request")
      k_signing
  end
  
  def get_encoded_policy_document( key, contentType, bucket, acl, x_amz_algorithm, x_amz_credential, x_amz_date )
    Base64.encode64( 
      {
        "expiration" => 15.minutes.from_now.utc.xmlschema,
        "conditions" => [
          { "bucket" =>  bucket },
          [ "eq", "$key", key ],
          { "acl" => acl },
          [ "eq", "$Content-Type", contentType ],
          {"x-amz-algorithm" => x_amz_algorithm },
          {"x-amz-credential" => x_amz_credential },
          {"x-amz-date" => x_amz_date},
          {"x-amz-security-token" => @roleSessionToken},
        ]
      }.to_json 
    ).gsub("\n","")
  end
  
  def get_signature( policy_date, s3_region, encoded_policy )
    signature_key = get_signature_key( @roleSecretAccessKey, policy_date , s3_region, "s3")

    OpenSSL::HMAC.hexdigest('sha256', signature_key, encoded_policy )
  end

end
