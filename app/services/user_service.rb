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
    user_params[:consumer_attributes][:sandbox_gateway_ref] ||= user.consumer.try(&:sandbox_gateway_ref)
    user_params[:consumer_attributes][:sandbox_oauth_ref] ||= user.consumer.try(&:sandbox_oauth_ref)
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
    consumer.sandbox_gateway_ref = sandbox_gateway_ref(params) if sandbox_gateway_ref(params).present?
    consumer.sandbox_oauth_ref = params[:okta_id] if params[:okta_id].present?
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
    params.dig(:user, :consumer_attributes, :sandbox_gateway_ref)
  end
end
