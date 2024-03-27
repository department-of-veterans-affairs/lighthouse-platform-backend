class LighthouseAuthService
  include HTTParty
  # will need to add to AWS and Deployment Unit Repo
  base_uri Figaro.env.lighthouse_auth_service

  OAUTH_TYPES = {
    acg: 'acg',
    ccg: 'ccg'
  }.freeze

  def self.consumer_signup(user, options = {})
    acg_application = consumer_signup_per_type(user, OAUTH_TYPES[:acg], options)
    ccg_application = consumer_signup_per_type(user, OAUTH_TYPES[:ccg], options)

    { acg: acg_application, ccg: ccg_application }
  end

  private

  def consumer_signup_per_type(user, type, options = {})
    oauth_apis = user.consumer.apis_list.select { |api| api.auth_type == type }
    return if oauth_apis.blank?

    response = create_application(user, type, options)
    parsed_response = JSON.parse(response)
    
    client_id = parsed_response['clientId']
    client_secret = parsed_response['clientSecret']
    redirect_uri = parsed_response['redirectUris']

    save_id_to_user(user, type, client_id)

    # Need to confirm the payload that DevPortal is expecting...
    {
      clientId: client_id,
      clientSecret: client_secret,
      redirectUri: redirect_uri
    }
  end

  def create_application(user, type, options)
    request_body = {
      'applicationName' => "#{user.consumer.organization}#{user.last_name}".gsub(/\W/, ''),
      'apiCategory' => 'IDK yet'
    }

    case type
    when 'acg'
      request_body['redirectUri'] = options[:redirect_uri]
      request_body['pkceRequired'] = 'IDK yet'
    when 'ccg'
      request_body['jwk'] = 'IDK yet'
    end

    post('app/create', body: request_body.to_json, headers: headers)
  end

  def self.headers
    {
      # will need to add to AWS and Deployment Unit Repo
      'apiKey' => Figaro.env.lighthouse_auth_api_key,
      'Content-Type' => 'application/json'
    }
  end

  def save_id_to_user(user, type, id)
    auth_ref_key = ConsumerAuthRef::KEYS["sandbox_#{type}_oauth_ref".to_sym]
    existing_auth_ref = user.consumer.consumer_auth_refs.kept.find_by(key: auth_ref_key)
    existing_auth_ref.discard if existing_auth_ref.present?
    auth_ref = ConsumerAuthRef.new(consumer: user.consumer, key: auth_ref_key, value: id)
    user.consumer.consumer_auth_refs.push(auth_ref)
    user.save!
    user.undiscard if user.discarded?
  end
end