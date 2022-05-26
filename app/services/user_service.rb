# frozen_string_literal: true

class UserService
  def construct_import(params, environment)
    user_params = params[:user].with_indifferent_access
    user = User.find_or_initialize_by(email: user_params[:email].downcase)
    user.undiscard if user.discarded?
    @api_list = if user.consumer.present?
                  user.consumer.apis.collect { |api| api.api_ref.name }
                else
                  []
                end
    apis = (@api_list << user_params[:consumer_attributes][:apis_list].split(',')).flatten.uniq
    user_params[:consumer_attributes][:apis_list] = nil
    user_params[:consumer_attributes][:consumer_auth_refs_attributes].delete_if do |auth_ref_attr|
      auth_ref_attr[:value].blank?
    end
    if keep?(user, user_params, 'sandbox_gateway_ref')
      user_params[:consumer_attributes][:consumer_auth_refs_attributes].push(
        {
          key: 'sandbox_gateway_ref',
          value: user.consumer.consumer_auth_refs.find_by(key: 'sandbox_gateway_ref')&.value
        }
      )
    end
    if keep?(user, user_params, 'sandbox_acg_oauth_ref')
      user_params[:consumer_attributes][:consumer_auth_refs_attributes].push(
        {
          key: 'sandbox_acg_oauth_ref',
          value: user.consumer.consumer_auth_refs.find_by(key: 'sandbox_acg_oauth_ref')&.value
        }
      )
    end
    user.assign_attributes(user_params)
    user.save
    create_or_update_consumer(user, params)

    update_api_list(user.consumer, apis, environment) if apis.present?
  end

  def update_api_list(consumer, apis, environment)
    apis.each do |api_name|
      next if api_name.blank?

      add_api_to_consumer(api_name, consumer, environment)
    end
  end

  def create_or_update_consumer(user, params)
    consumer = user.consumer
    consumer.undiscard if consumer.discarded?
    consumer.description = params[:description]
    consumer.organization = params[:organization]
    consumer.consumer_auth_refs.push(sandbox_gateway_ref(params)) if sandbox_gateway_ref(params).present?
    consumer.consumer_auth_refs.push(sandbox_acg_oauth_ref(params)) if sandbox_acg_oauth_ref(params).present?
    consumer.tos_accepted_at = Time.zone.now
    consumer.tos_version = Figaro.env.current_tos_version
    consumer.save if consumer.valid?
  end

  private

  def add_api_to_consumer(api_name, consumer, environment)
    api_ref = ApiRef.find_by(name: api_name.strip)
    if api_ref.blank?
      Rails.logger.warn "??? #{api_name.strip} api_ref not found when importing consumer"
      return
    end

    api_id = api_ref[:api_id]
    api_model = Api.find(api_id)
    env = Environment.find_by(name: environment)
    api_environment = ApiEnvironment.find_by(environment: env, api: api_model)
    if api_environment.present? && consumer.api_environment_ids.exclude?(api_environment.id)
      consumer.api_environments << api_environment
    end
    consumer.save
  end

  def sandbox_gateway_ref(params)
    ref_value = params.dig(:user, :consumer_attributes, :consumer_auth_refs_attributes)&.detect do |auth_ref|
      auth_ref[:key] == 'sandbox_gateway_ref'
    end&.dig(:value)

    return if ref_value.blank?

    ConsumerAuthRef.new(key: 'sandbox_gateway_ref', value: ref_value)
  end

  def sandbox_acg_oauth_ref(params)
    ref_value = params.dig(:user, :consumer_attributes, :consumer_auth_refs_attributes)&.detect do |auth_ref|
      auth_ref[:key] == 'sandbox_acg_oauth_ref'
    end&.dig(:value)

    return if ref_value.blank?

    ConsumerAuthRef.new(key: 'sandbox_acg_oauth_ref', value: ref_value)
  end

  def keep?(user, user_params, key)
    user_params.dig(:consumer_attributes, :consumer_auth_refs_attributes)&.detect do |auth_ref|
      auth_ref[:key] == key
    end.blank? && user.consumer&.consumer_auth_refs&.find_by(key: key)&.value.present?
  end
end
