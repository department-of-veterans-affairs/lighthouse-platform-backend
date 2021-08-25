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

  def update_kong_consumers
    @kong_consumers.map do |k_consumer|
      consumer = @dynamo_consumers.find { |d_consumer| k_consumer['id'] == d_consumer['kongConsumerId'] }
      if consumer && consumer['tosAccepted']
        okta_id = consumer['okta_application_id'] unless @okta_applications.find do |okta_app|
          okta_app['id'] == consumer['okta_application_id']
        end.nil?

        # if Dynamo record
        UserService.new.construct_import(consumer, k_consumer['id'], okta_id) if consumer['email'].present?
        @dynamo_consumers.delete(consumer)
      end
    end
  end

  def update_dynamo_consumers
    @dynamo_consumers.map do |dyn_consumer|
      if dyn_consumer['tosAccepted']
        okta_application = @okta_applications.find { |okta_app| okta_app['id'] == dyn_consumer['okta_application_id'] }
        UserService.new.construct_import(dyn_consumer, nil, okta_application['id']) if okta_application
      end
    end
  end
end
