# frozen_string_literal: true

class ConsumerImportService
  attr_accessor :kong_consumers, :dynamo_consumers, :okta_applications, :users_list

  def initialize
    @kong_consumers = Kong::SandboxService.new.list_all_consumers
    @dynamo_consumers = DynamoService.new.fetch_dynamo_db.items
    @okta_applications = Okta::SandboxService.new.list_applications
  end

  def import
    update_kong_consumers
    update_dynamo_consumers
  end

  def build_user_from_dynamo(consumer, gateway_id, oauth_id)
    consumer = consumer.with_indifferent_access
    user = {
      user: {
        email: consumer['email'],
        first_name: consumer['firstName'],
        last_name: consumer['lastName'],
        consumer_attributes: {
          description: consumer['description'],
          organization: consumer['organization'],
          consumer_auth_refs_attributes: [],
          apis_list: consumer['apis'],
          tos_accepted: consumer['tosAccepted']
        }
      }
    }

    if gateway_id.present?
      user[:user][:consumer_attributes][:consumer_auth_refs_attributes].push(
        { key: ConsumerAuthRef::KEYS[:sandbox_gateway_ref], value: gateway_id }
      )
    end

    if oauth_id.present?
      user[:user][:consumer_attributes][:consumer_auth_refs_attributes].push(
        { key: ConsumerAuthRef::KEYS[:sandbox_acg_oauth_ref], value: oauth_id }
      )
    end

    user.with_indifferent_access
  end

  def update_kong_consumers
    @kong_consumers.map do |kong_consumer|
      consumer = @dynamo_consumers.find { |d_consumer| kong_consumer['id'] == d_consumer['kongConsumerId'] }
      if consumer && consumer['tosAccepted']
        consumer = consumer.with_indifferent_access
        update_kong_consumer(consumer, kong_consumer)
      end
    end
  end

  def update_kong_consumer(dynamo_consumer, consumer)
    okta_id = dynamo_consumer['okta_application_id'] unless @okta_applications.find do |okta_app|
      okta_app[:id] == dynamo_consumer['okta_application_id']
    end.nil?

    user_model = build_user_from_dynamo(dynamo_consumer, consumer['id'], okta_id)

    UserService.new.construct_import(user_model, 'sandbox') if dynamo_consumer['email'].present?
    @dynamo_consumers.delete(dynamo_consumer)
  end

  def update_dynamo_consumers
    @dynamo_consumers.map do |dyn_consumer|
      dyn_consumer = dyn_consumer.with_indifferent_access
      if dyn_consumer['tosAccepted']
        okta_application = @okta_applications.find { |okta_app| okta_app[:id] == dyn_consumer['okta_application_id'] }
        if okta_application
          user_model = build_user_from_dynamo(dyn_consumer, nil, okta_application['id'])

          UserService.new.construct_import(user_model, 'sandbox')
        end
      end
    end
  end
end
