# frozen_string_literal: true

class ExportService
  OKTA_AUTH_TYPES = {
    client_secret: 'client_secret_basic',
    client_credentials: 'private_key_jwk'
  }.freeze
  def initialize(environment)
    @okta_service = Okta::ServiceFactory.service(environment)
    @kong_service = Kong::ServiceFactory.service(environment)
  end

  def kong_key_access_list
    consumer_list = @kong_service.list_all_consumers
    env_acls = @kong_service.get_all_acls['data']
    kong_keys = @kong_service.get_all_keys['data']

    [].tap do |a|
      consumer_list.each do |consumer|
        consumer_acls = env_acls.filter { |acl| acl['consumer']['id'] == consumer['id'] }
        api_products = filter_acls(consumer_acls)
        keys = kong_keys.select { |key| key['consumer']['id'] == consumer['id'] }
        if keys.length.positive?
          a << { id: consumer['id'], username: consumer['username'], key: keys.map { |key| key['key'] },
                 apiProducts: api_products }
        end
      end
    end
  end

  def gather_active_okta_apis
    apis = Api.all.map(&:auth_server_access_key).uniq.compact
    {}.tap do |a|
      apis.map { |api| a[api] = [Figaro.env.send(api), Figaro.env.send("#{api}_ccg"), Figaro.env.send("#{api}_acg")] }
    end
  end

  def construct_okta_list(okta_consumers, okta_auth_servers)
    [].tap do |o|
      okta_consumers.each do |consumer|
        servers = okta_auth_servers.filter { |auth_server| auth_server[:include].include?(consumer[:id]) }
        if servers.present?
          auth_type = consumer.dig(:credentials, :oauthClient, :token_endpoint_auth_method)
          if auth_type.present? && auth_type == OKTA_AUTH_TYPES[:client_secret]
            app_secrets = @okta_service.list_secret_credentials_for_application(consumer[:id])
          end
          per_id = { clientId: consumer[:id], apiProducts: [], label: consumer[:label] }
          per_id[:clientSecret] = app_secrets.first[:client_secret] if app_secrets.present?
          servers.each do |server|
            api = Api.find_by(auth_server_access_key: server[:api])
            unless api.nil?
              per_id[:apiProducts] << api.name
              o << per_id
            end
          end
        end
      end
    end
  end

  def okta_consumer_list
    okta_consumers = retrieve_active_applications

    api_list = gather_active_okta_apis

    auth_servers = @okta_service.list_authorization_servers
    current_auth_servers = active_auth_servers(auth_servers, api_list)
    okta_auth_servers = fetch_included_consumers(current_auth_servers, api_list)

    construct_okta_list(okta_consumers, okta_auth_servers)
  end

  def filter_acls(consumer_acls)
    [].tap do |api_product|
      consumer_acls.map do |acl|
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

  def randomize_excess_data(data, _idx)
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    user = {
      developer: {
        email: Faker::Internet.email(name: 'Unknown', domain: 'example'),
        firstName: "LPB#{first_name}",
        lastName: "LPB#{last_name}",
        username: data[:username] || data[:label]
      },
      keys: []
    }
    user[:keys] << if data[:key].present?
                     { apiKey: { key: data[:key], apiProducts: data[:apiProducts] } }
                   else
                     type = data[:clientSecret].blank? ? 'oAuthCcg' : 'oAuthAcg'
                     { type => { clientId: data[:clientId], clientSecret: data[:clientSecret],
                                 apiProducts: data[:apiProducts] } }
                   end
    user
  end
end
