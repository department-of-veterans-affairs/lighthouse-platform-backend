namespace :apis do
  desc 'load the initial APIs'
  task load: :environment do
    # template
    # Api.create({
    #   name: '',
    #   auth_method: '',
    #   environment: '',
    #   open_api_url: '',
    #   base_path: '',
    #   service_ref: '',
    #   api_ref: ''
    # })

    ###########
    # Staging #
    ###########

    # Appeals v0
    Api.create({
      name: 'Appeals Status API',
      auth_method: 'key_auth',
      environment: 'staging',
      open_api_url: '/services/appeals/docs/v0/api',
      base_path: '/services/appeals/v0/appeals',
      service_ref: '49edf38e-bbfc-4256-9162-9adaa2e0798f',
      api_ref: 'appeals'
    })

    # Appeals v1
    Api.create({
      name: 'Decision Reviews API',
      auth_method: 'key_auth',
      environment: 'staging',
      open_api_url: '/services/appeals/docs/v1/decision_reviews',
      base_path: '/services/appeals/v1/decision_reviews',
      service_ref: '72e0f044-ddc2-4303-990b-c858fa2b5cab',
      api_ref: 'decision_reviews'
    })

    # Forms v0
    Api.create({
      name: 'VA Forms API',
      auth_method: 'key_auth',
      environment: 'staging',
      open_api_url: '/internal/docs/forms/v0/openapi.json',
      base_path: '/services/va_forms/v0',
      service_ref: '48b34d5a-f822-4446-830c-fb212077f17c',
      api_ref: 'vaForms'
    })

    # Vet Verification v0
    Api.create({
      name: 'Address Validation API',
      auth_method: 'key_auth',
      environment: 'staging',
      open_api_url: '/internal/docs/address-validation/v1/openapi.json',
      base_path: '/services/veteran_confirmation/v0',
      service_ref: '3ed65563-a63d-4e25-8c3d-353f910c07e6',
      api_ref: 'confirmation'
    })
  end
end