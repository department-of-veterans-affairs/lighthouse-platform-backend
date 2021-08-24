# frozen_string_literal: true

class UserService
  def construct_import(params, kong_id, okta_id)
    attributes = {
      user: {
        email: params['email'],
        first_name: params['firstName'],
        last_name: params['lastName'],
        consumer_attributes: {
          description: params['description'],
          organization: params['organization'],
          sandbox_gateway_ref: kong_id,
          sandbox_oauth_ref: okta_id,
          apis_list: params['consumer_attributes']['apis_list'],
          tos_accepted: params['tosAccepted']
        }
      }
    }
    user = User.find_or_initialize_by(email: attributes[:user][:email])
    @api_list = if user.consumer.present?
                  user.consumer.apis.map(&:api_ref)
                else
                  []
                end
    apis = (@api_list << attributes[:user][:consumer_attributes][:apis_list]).uniq
    attributes[:user][:consumer_attributes][:sandbox_gateway_ref] ||= user.consumer.try(&:sandbox_gateway_ref)
    attributes[:user][:consumer_attributes][:sandbox_oauth_ref] ||= user.consumer.try(&:sandbox_oauth_ref)
    # we will re-assign these later
    attributes[:user][:consumer_attributes][:apis_list] = nil
    user.assign_attributes(attributes[:user])
    user.save
    consumer = user.consumer
    consumer.description = params['description']
    consumer.organization = params['organization']
    if attributes[:user][:consumer_attributes][:sandbox_gateway_ref].present?
      consumer.sandbox_gateway_ref = attributes[:user][:consumer_attributes][:sandbox_gateway_ref]
    end
    consumer.sandbox_oauth_ref = params['okta_id'] if params['okta_id'].present?
    consumer.tos_accepted_at = Time.zone.now
    consumer.tos_version = Figaro.env.current_tos_version
    consumer.save

    apis.each do |api_name|
      api = Api.find_by api_ref: api_name.strip
      consumer.apis << api if api.present?
      consumer.save
    end
  end
end
