# frozen_string_literal: true

class ConsumerImportService
  attr_accessor :kong_consumers, :dynamo_consumers, :okta_applications, :users_list

  def initialize
    @kong_consumers = KongService.new.list_all_consumers
    @dynamo_consumers = DynamoService.new.fetch_dynamo_db.items
    @okta_applications = OktaService.new.list_applications
  end

  def import
    update_dynamo_consumers
  end

  def update_dynamo_consumers
    @dynamo_consumers.map do |dyn_consumer|
      dyn_consumer = dyn_consumer.with_indifferent_access
      if dyn_consumer['tosAccepted']
        okta_application = @okta_applications.find { |okta_app| okta_app['id'] == dyn_consumer['okta_application_id'] }
        if okta_application
          user_model = build_user_from_dynamo(dyn_consumer, nil, okta_application['id'])

          UserService.new.construct_import(user_model)
        end
      end
    end
  end

  def build_user_from_dynamo(consumer, gateway_id, oauth_id)
    consumer = consumer.with_indifferent_access
    {
      user: {
        email: consumer['email'],
        first_name: consumer['firstName'],
        last_name: consumer['lastName'],
        consumer_attributes: {
          description: consumer['description'],
          organization: consumer['organization'],
          sandbox_gateway_ref: gateway_id,
          sandbox_oauth_ref: oauth_id,
          apis_list: consumer['apis'],
          tos_accepted: consumer['tosAccepted']
        }
      }
    }.with_indifferent_access
  end
end
