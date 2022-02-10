# frozen_string_literal: true

apis = CSV.parse(File.read('spec/support/apis_list.csv'), headers: true)
apis = apis.each do |api|
  api_record = Api.create(name: api['api_name'])
  api_record.assign_attributes(acl: api['acl_ref'].to_i,
                               auth_server_access_key: api.dig('api', 'auth_server_access_key'),
                               api_environments_attributes: {
                                 metadata_url: api['metadata_url'],
                                 environments_attributes: {
                                   name: api['environment']
                                 }
                               },
                               api_ref_attributes: {
                                 name: api['api_ref']
                               },
                               api_metadatum_attributes: {
                                 description: api['api_description'],
                                 display_name: api['display_name'],
                                 open_data: api['open_data'],
                                 va_internal_only: api['va_internal_only'],
                                 api_category_attributes: {
                                   name: api['category_name'],
                                   short_description: api['category_short_description'],
                                   quickstart: api['category_quickstart'],
                                   veteran_redirect_link_url: api['category_veteran_redirect_link_url'],
                                   veteran_redirect_link_text: api['category_veteran_redirect_link_text'],
                                   veteran_redirect_message: api['category_veteran_redirect_message'],
                                   overview: api['category_overview']
                                 }
                               })
end
