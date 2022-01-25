# frozen_string_literal: true

class UserService
  def construct_import(params)
    user_params = params[:user].with_indifferent_access
    user = User.find_or_initialize_by(email: user_params[:email].downcase)
    user.undiscard if user.discarded?
    build_api_list user

    apis = (@api_list << user_params[:consumer_attributes][:apis_list].split(',')).flatten.uniq
    user_params[:consumer_attributes][:apis_list] = nil
    user_params[:consumer_attributes][:sandbox_gateway_ref] ||= user.consumer.try(&:sandbox_gateway_ref)
    user_params[:consumer_attributes][:sandbox_oauth_ref] ||= user.consumer.try(&:sandbox_oauth_ref)
    user.assign_attributes(user_params)
    user.save
    create_or_update_consumer(user, params)

    update_api_list(user.consumer, apis) if apis.present?
  end

  def update_api_list(consumer, apis)
    apis.each do |api_name|
      next if api_name.blank?

      api_id = ApiRef.find_by(name: api_name.strip)[:api_id]
      api = Api.find(api_id)
      environment = Environment.find_by(name: Figaro.env.lpb_environment)
      handle_consumers_api_associations(consumer, environment, api) if environment && api
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

  def build_api_list(user)
    @api_list = if user.consumer.present?
                  user.consumer.consumer_api_assignments.map(&:api_environment).map(&:api).map(&:api_ref).map(&:name)
                else
                  []
                end
  end

  def handle_consumers_api_associations(consumer, environment, api)
    api_environment = ApiEnvironment.find_by(environment: environment, api: api)
    consumer_api_assignment = ConsumerApiAssignment.find_or_initialize_by(api_environment: api_environment,
                                                                          consumer: consumer)
    unless consumer.consumer_api_assignments.include?(consumer_api_assignment)
      consumer.consumer_api_assignments << consumer_api_assignment
    end
    consumer.save
  end

  def sandbox_gateway_ref(params)
    params.dig(:user, :consumer_attributes, :sandbox_gateway_ref)
  end
end
