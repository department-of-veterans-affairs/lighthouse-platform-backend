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
    create_or_update_consumer(user, user_params)

    update_api_list(user.consumer, apis, environment) if apis.present?
  end

  def update_api_list(consumer, apis, environment)
    apis.each do |api_name|
      next if api_name.blank?

      add_api_to_consumer(api_name, consumer, environment)
    end
  end

  def create_or_update_consumer(user, user_params)
    consumer = user.consumer
    consumer.undiscard if consumer.discarded?
    consumer.description = user_params.dig(:consumer_attributes, :description)
    consumer.organization = user_params.dig(:consumer_attributes, :organization)
    consumer.tos_accepted_at = Time.zone.now
    consumer.tos_version = Figaro.env.current_tos_version
    return unless consumer.valid?

    consumer.save

    sgr = sandbox_gateway_ref(user_params, consumer)
    consumer.consumer_auth_refs.push(sgr) if sgr.present?
    saor = sandbox_acg_oauth_ref(user_params, consumer)
    consumer.consumer_auth_refs.push(saor) if saor.present?
    return unless consumer.valid?

    consumer.save
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

  def sandbox_gateway_ref(user_params, consumer)
    ref_value = user_params.dig(:consumer_attributes, :consumer_auth_refs_attributes)&.detect do |auth_ref|
      auth_ref[:key] == 'sandbox_gateway_ref'
    end&.dig(:value)

    return if ref_value.blank?
    return if existing_ref(consumer, 'sandbox_gateway_ref', ref_value).present?

    auth_ref = ConsumerAuthRef.new(key: 'sandbox_gateway_ref', value: ref_value, consumer_id: consumer.id)
    return auth_ref if existing_ref(consumer, 'sandbox_gateway_ref').blank?

    auth_ref.discard
    auth_ref
  end

  def sandbox_acg_oauth_ref(user_params, consumer)
    ref_value = user_params.dig(:consumer_attributes, :consumer_auth_refs_attributes)&.detect do |auth_ref|
      auth_ref[:key] == 'sandbox_acg_oauth_ref'
    end&.dig(:value)

    return if ref_value.blank?
    return if existing_ref(consumer, 'sandbox_acg_oauth_ref', ref_value).present?

    auth_ref = ConsumerAuthRef.new(key: 'sandbox_acg_oauth_ref', value: ref_value, consumer_id: consumer.id)
    return auth_ref if existing_ref(consumer, 'sandbox_acg_oauth_ref').blank?

    auth_ref.discard
    auth_ref
  end

  def existing_ref(consumer, key, ref_value = nil)
    return ConsumerAuthRef.find_by(key: key, consumer_id: consumer.id).present? if ref_value.blank?

    existing = ConsumerAuthRef.find_by(key: key, value: ref_value, consumer_id: consumer.id)
    return if existing.blank?

    existing.undiscard
    nil
  end

  def keep?(user, user_params, key)
    user_params.dig(:consumer_attributes, :consumer_auth_refs_attributes)&.detect do |auth_ref|
      auth_ref[:key] == key
    end.blank? && user.consumer&.consumer_auth_refs&.find_by(key: key)&.value.present?
  end
end
