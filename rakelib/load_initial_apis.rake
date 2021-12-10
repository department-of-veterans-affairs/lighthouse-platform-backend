# frozen_string_literal: true

desc 'load initial APIs on current gateway'
task load_apis: :environment do |_, args|
  require 'csv'
  file_path = args.extras.first
  host = args.extras.last
  url = "#{host}/platform-backend/admin/api/v0/apis/bulk_upload"
  apis_list = CSV.parse(File.read(file_path), headers: true)
  apis_list = apis_list.map do |api|
    {
      api: {
        name:	api['api_name'],
        acl: api['acl_ref'].to_i,
        metadata_url: api['metadata_url'],
        env_name: api['environment'],
        api_ref: api['api_ref']
      }
    }
  end
  JSON.parse(RestClient.post(url, { apis: apis_list }).body)
end
