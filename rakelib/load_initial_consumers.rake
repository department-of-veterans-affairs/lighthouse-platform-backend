# frozen_string_literal: true

desc 'loads the initial user, consumer and their API list'
task load_consumers: :environment do |_, args|
  host = args.extras.first
  url = "#{host}/platform-backend/consumers"

  kong_consumers = KongService.new.list_all_consumers
  dynamo_consumers = DynamoService.new.fetch_dynamo_db.items
  okta_applications = OktaService.new.list_applications
  users_list = []

  kong_consumers.map do |k_consumer|
    consumer = dynamo_consumers.find { |d_consumer| k_consumer['id'] == d_consumer['kongConsumerId'] }

    if consumer && consumer['tosAccepted']
      okta_id = consumer['okta_application_id'] unless okta_applications.find do |okta_app|
                                                         okta_app['id'] == consumer['okta_application_id']
                                                       end.nil?
      users_list << UserService.new.construct_import(consumer, k_consumer['id'], okta_id)
      dynamo_consumers.delete(consumer)
    end
  end

  dynamo_consumers.map do |dyn_consumer|
    if dyn_consumer['tosAccepted']
      okta_application = okta_applications.find { |okta_app| okta_app['id'] == dyn_consumer['okta_application_id'] }
      users_list << UserService.new.construct_import(dyn_consumer, nil, okta_application['id']) if okta_application
    end
  end

  users_list.each do |user|
    JSON.parse(RestClient.post(url, user).body)
  end
end
