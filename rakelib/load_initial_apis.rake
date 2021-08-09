# frozen_string_literal: true

desc 'load initial APIs on current gateway'
task load_apis: :environment do |_, args|
  require 'csv'
  file_path = args.extras.first
  host = args.extras.last
  url = "#{host}/platform-backend/admin/api/v0/apis"
  apis_list = CSV.parse(File.read(file_path), headers: true)
  puts apis_list.inspect
  apis_list.each do |api|
    Rails.logger.warn "------- #{api['api_name']} -------"
    params = {
      api: {
        name:	api.first.last,
        version: api['version'].to_i,
        auth_method: api['auth_method'],
        environment: api['environment'],
        open_api_url: api['open_api_url'],
        base_path: api['base_path'],
        service_ref: api['service_ref']
      }
    }
    JSON.parse(RestClient.post(url, params).body)
  end
end
