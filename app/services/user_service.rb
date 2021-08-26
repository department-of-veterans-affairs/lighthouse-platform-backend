# frozen_string_literal: true

class UserService
  def construct_import(params)
    user_params = params[:user]
    user = User.find_or_initialize_by(email: user_params[:email].downcase)
    @api_list = if user.consumer.present?
                  user.consumer.apis.map(&:api_ref)
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

    update_api_list(user.consumer, apis) if apis.present?
  end

  def update_api_list(consumer, apis)
    apis.each do |api_name|
      # FIX MY NIL ISSUE BEFORE PR :)

      next if api_name.blank?

      api = Api.find_by(api_ref: api_name.strip, environment: 'sandbox')
      consumer.apis << api if api.present?
      consumer.save
    end
  end

  def create_or_update_consumer(user, params)
    consumer = user.consumer
    consumer.description = params[:description]
    consumer.organization = params[:organization]
    if params[:user][:consumer_attributes][:sandbox_gateway_ref].present?
      consumer.sandbox_gateway_ref = params[:user][:consumer_attributes][:sandbox_gateway_ref]
    end
    consumer.sandbox_oauth_ref = params[:okta_id] if params[:okta_id].present?
    consumer.tos_accepted_at = Time.zone.now
    consumer.tos_version = Figaro.env.current_tos_version
    consumer.save if consumer.valid?
  end
end
