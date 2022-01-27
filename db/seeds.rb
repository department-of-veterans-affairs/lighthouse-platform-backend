# frozen_string_literal: true

apis = CSV.parse(File.read('spec/support/apis_list.csv'), headers: true)
apis = apis.each do |api|
  Api.create(name: api['api_name'],
             acl: api['acl_ref'].to_i,
             auth_server_access_key: api.dig('api', 'auth_server_access_key'),
             api_environments_attributes: {
               metadata_url: api['metadata_url'],
               environments_attributes: {
                 name: api['environment']
               }
             },
             api_ref_attributes: {
               name: api['api_ref']
             })
end
