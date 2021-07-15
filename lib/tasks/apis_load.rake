namespace :apis do
  desc 'load the initial APIs'
  task load: :environment do
    Api.create({
      name: 'Community Care Eligibility API',
      auth_method: 'key_auth',
      environment: 'staging',
      open_api_url: 'https://yep.com/services/community-care/v0/eligibility/openapi.json',
      base_path: 'services/community-care/v0',
      service_ref: '025ad0210k08k-109koqkdfjo0-33qlaiz',
      api_ref: 'communityCare'
    })
  end
end