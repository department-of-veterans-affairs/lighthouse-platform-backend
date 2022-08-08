# frozen_string_literal: true

class ExportService
  def initialize(environment)
    @okta_service = Okta::ServiceFactory.service(environment)
    @kong_service = Kong::ServiceFactory.service(environment)
  end

  def kong_consumer_key_list
    consumer_list = @kong_service.list_all_consumers
    env_acls = @kong_service.get_all_acls['data']
    kong_keys = @kong_service.get_all_keys['data']

    build_kong_consumer_list(consumer_list, env_acls, kong_keys)
  end

  def build_kong_consumer_list(consumer_list, env_acls, kong_keys)
    [].tap do |a|
      consumer_list.each do |consumer|
        consumer_acls = env_acls.filter { |acl| acl['consumer']['id'] == consumer['id'] }
        keys = kong_keys.select { |key| key['consumer']['id'] == consumer['id'] }
        if keys.length.positive?
          a << { id: consumer['id'], username: consumer['username'], key: keys.map { |key| key['key'] },
                 apiProducts: filter_acls(consumer_acls) }
        end
      end
    end
  end

  def gather_active_okta_apis
    apis = Api.all.map(&:auth_server_access_key).uniq.compact
    {}.tap do |a|
      apis.map do |api|
        a[api] = [Figaro.env.send(api), Figaro.env.send("#{api}_ccg"), Figaro.env.send("#{api}_acg")].compact
      end
    end
  end

  def construct_okta_consumer_list(okta_consumers, okta_auth_servers)
    [].tap do |o|
      okta_consumers.each do |consumer|
        manage_okta_consumer(consumer, okta_auth_servers, o)
      end
    end
  end

  def manage_okta_consumer(consumer, auth_servers, list)
    servers = auth_servers.filter { |auth_server| auth_server[:include].include?(consumer[:id]) }
    if servers.present?
      app_secrets = request_secrets(consumer)
      okta_consumer = okta_consumer_data(consumer, app_secrets)
      add_api_products(servers, okta_consumer, list)
    end
  end

  def okta_consumer_data(consumer, app_secrets)
    okta_consumer = { clientId: consumer[:id], apiProducts: [], label: consumer[:label] }
    okta_consumer[:clientSecret] = app_secrets.first[:client_secret] unless app_secrets.nil?
    okta_consumer
  end

  def request_secrets(consumer)
    auth_type = consumer.dig(:credentials, :oauthClient, :token_endpoint_auth_method)
    if auth_type.present? && auth_type == 'client_secret_basic'
      app_secrets = @okta_service.list_secret_credentials_for_application(consumer[:id])
    end
    app_secrets
  end

  def add_api_products(servers, consumer, list)
    servers.each do |server|
      api = Api.find_by(auth_server_access_key: server[:api])
      unless api.nil?
        consumer[:apiProducts] << api.name
        list << consumer
      end
    end
  end

  def okta_consumer_list
    okta_consumers = retrieve_active_applications

    api_list = gather_active_okta_apis

    auth_servers = @okta_service.list_authorization_servers
    current_auth_servers = active_auth_servers(auth_servers, api_list)
    okta_auth_servers = fetch_included_consumers(current_auth_servers, api_list)

    construct_okta_consumer_list(okta_consumers, okta_auth_servers)
  end

  def filter_acls(consumer_acls)
    [].tap do |api_product|
      consumer_acls.each do |acl|
        api = Api.find_by(acl: acl['group'])
        api_product << api.name unless api.nil?
      end
    end
  end

  def retrieve_active_applications
    @okta_service.list_applications.filter do |app|
      app[:name]&.downcase == 'oidc_client' && app[:status]&.downcase == 'active'
    end
  end

  def active_auth_servers(auth_servers, api_list)
    auth_servers.select do |auth_server|
      api_list.find { |_key, values| values.include?(auth_server[:id]) }.present?
    end
  end

  def fetch_included_consumers(current_auth_servers, api_list)
    [].tap do |s|
      current_auth_servers.each do |auth_server|
        policies = @okta_service.list_authorization_server_policies(auth_server[:id])
        default_policy = policies.detect { |policy| policy[:name] == Figaro.env.okta_default_policy }
        default_policy = policies.detect { |policy| policy[:name] == '*/* (all scopes)' } if default_policy.blank?
        api_auth_server = api_list.select { |_key, value| value.include?(auth_server[:id]) }.first.first
        s << { name: auth_server[:name], include: default_policy[:conditions][:clients][:include],
               api: api_auth_server }
      end
    end
  end

  def build_random_user(data, idx)
    {
      developer: {
        email: Faker::Internet.email(name: "Unknown#{idx}", domain: 'example'),
        firstName: "LPB#{Faker::Name.first_name}",
        lastName: "LPB#{Faker::Name.last_name}",
        username: data[:username] || data[:label]
      },
      keys: []
    }
  end

  def randomize_excess_data(data, idx)
    user = build_random_user(data, idx)
    key = if data[:key].present?
            structure_key_auth(data)
          else
            structure_oauth(data)
          end
    user[:keys] << key
    user
  end

  def structure_oauth(data)
    type = data[:clientSecret].blank? ? 'oAuthCcg' : 'oAuthAcg'
    key = {}
    key[type.to_sym] = { clientId: data[:clientId], apiProducts: data[:apiProducts] }
    key[type.to_sym][:clientSecret] = data[:clientSecret] if data[:clientSecret].present?
    key
  end

  def structure_key_auth(data)
    { apiKey: { key: data[:key], apiProducts: data[:apiProducts] } }
  end
end
