# frozen_string_literal: true

class ConsumerImportService
  attr_accessor :kong_consumers, :dynamo_consumers, :okta_applications, :users_list

  def initialize
    @kong_consumers = KongService.new.list_all_consumers
    @dynamo_consumers = DynamoService.new.fetch_dynamo_db.items
    @okta_applications = OktaService.new.list_applications
  end

  def import
    update_kong_consumers
    update_dynamo_consumers
  end

  def build_user_from_dynamo(consumer, gateway_id, oauth_id)
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
    }
  end

  def update_kong_consumers
    @kong_consumers.map do |k_consumer|
      consumer = @dynamo_consumers.find { |d_consumer| k_consumer['id'] == d_consumer['kongConsumerId'] }
      if consumer && consumer['tosAccepted']
        okta_id = consumer['okta_application_id'] unless @okta_applications.find do |okta_app|
          okta_app['id'] == consumer['okta_application_id']
        end.nil?

        user_model = build_user_from_dynamo(consumer, k_consumer['id'], okta_id)

        UserService.new.construct_import(user_model) if consumer['email'].present?
        @dynamo_consumers.delete(consumer)
      end
    end
  end

  def update_dynamo_consumers
    @dynamo_consumers.map do |dyn_consumer|
      if dyn_consumer['tosAccepted']
        okta_application = @okta_applications.find { |okta_app| okta_app['id'] == dyn_consumer['okta_application_id'] }
        if okta_application
          user_model = build_user_from_dynamo(dyn_consumer, nil, okta_application['id'])

          UserService.new.construct_import(user_model)
        end
      end
    end
  end
end
