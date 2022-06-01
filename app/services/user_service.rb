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
    user_params[:consumer_attributes][:consumer_auth_refs_attributes] = auth_refs(user, user_params)
    user_params[:consumer_attributes][:tos_accepted_at] = Time.zone.now
    user_params[:consumer_attributes][:tos_version] = Figaro.env.current_tos_version
    user.assign_attributes(user_params)
    user.save

    update_api_list(user.consumer, apis, environment) if apis.present?
  end

  def update_api_list(consumer, apis, environment)
    apis.each do |api_name|
      next if api_name.blank?

      add_api_to_consumer(api_name, consumer, environment)
    end
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

  def auth_refs(user, user_params)
    consumer_auth_refs_attributes = user_params[:consumer_attributes][:consumer_auth_refs_attributes]

    refs = []
    ConsumerAuthRef::KEYS.each do |_key, value|
      passed_in = consumer_auth_refs_attributes.detect { |ref| ref[:key] == value }
      existing = ConsumerAuthRef.find_by(key: value, consumer_id: user.consumer.id) if user.consumer&.id.present?

      if passed_in && !existing
        refs.push(passed_in)
      elsif existing && !passed_in
        refs.push({ key: value, value: existing.value })
      elsif passed_in && existing && passed_in[:value] != existing.value
        refs.push(passed_in)
        refs.push({ key: value, value: existing.value, discarded_at: Time.zone.now })
      end
    end

    refs
  end
end
