# frozen_string_literal: true

class UserService
  def construct_import(consumer, kong_id, okta_id)
    {
      user: {
        email: consumer['email'],
        first_name: consumer['firstName'],
        last_name: consumer['lastName'],
        consumer_attributes: {
          description: consumer['description'],
          organization: consumer['organization'],
          sandbox_gateway_ref: kong_id,
          sandbox_oauth_ref: okta_id,
          apis_list: consumer['apis'],
          tos_accepted: consumer['tosAccepted']
        }
      }
    }
  end
end
