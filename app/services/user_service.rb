# frozen_string_literal: true

class UserService
  def construct_import(params, gateway_id, oauth_id)
    attributes = fetch_attributes(params, gateway_id, oauth_id)
    user = User.find_or_initialize_by(email: attributes[:user][:email].downcase)
    @api_list = if user.consumer.present?
                  user.consumer.apis.map(&:api_ref)
                else
                  []
                end
    apis = (@api_list << params['apis'].split(',')).flatten.uniq
    attributes[:user][:consumer_attributes][:sandbox_gateway_ref] ||= user.consumer.try(&:sandbox_gateway_ref)
    attributes[:user][:consumer_attributes][:sandbox_oauth_ref] ||= user.consumer.try(&:sandbox_oauth_ref)
    user.assign_attributes(attributes[:user])
    user.save

    create_or_update_consumer(user, attributes, params)

    update_api_list(user.consumer, apis) if apis.present?
  end

  def update_api_list(consumer, apis)
    apis.each do |api_name|
      # FIX MY NIL ISSUE BEFORE PR :)

      next if api_name.blank?

      api = Api.find_by api_ref: api_name.strip
      consumer.apis << api if api.present?
      consumer.save
    end
  end

  def create_or_update_consumer(user, attributes, params)
    consumer = user.consumer
    consumer.description = params['description']
    consumer.organization = params['organization']
    if attributes[:user][:consumer_attributes][:sandbox_gateway_ref].present?
      consumer.sandbox_gateway_ref = attributes[:user][:consumer_attributes][:sandbox_gateway_ref]
    end
    consumer.sandbox_oauth_ref = params['okta_id'] if params['okta_id'].present?
    consumer.tos_accepted_at = Time.zone.now
    consumer.tos_version = Figaro.env.current_tos_version
    consumer.save if consumer.valid?
  end

  # rubocop:disable Metrics/MethodLength
  def fetch_attributes(params, gateway_id, oauth_id)
    {
      user: {
        email: params['email'],
        first_name: params['firstName'],
        last_name: params['lastName'],
        consumer_attributes: {
          description: params['description'],
          organization: params['organization'],
          sandbox_gateway_ref: gateway_id,
          sandbox_oauth_ref: oauth_id,
          apis_list: nil,
          tos_accepted: params['tosAccepted']
        }
      }
    }
  end
  # rubocop:enable Metrics/MethodLength
end
