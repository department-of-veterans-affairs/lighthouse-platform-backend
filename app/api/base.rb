# frozen_string_literal: true

class Base < Grape::API
  format :json
  rescue_from Grape::Exceptions::ValidationErrors do |e|
    error!({ errors: [Entities::ErrorEntity.represent({ title: 'Bad Request',
                                                        detail: e.message })] }, 400)
  end
  rescue_from Grape::Exceptions::Validation do |e|
    error!({ errors: [Entities::ErrorEntity.represent({ title: 'Bad Request',
                                                        detail: e.message })] }, 400)
  end
  rescue_from ActiveRecord::RecordNotFound do |_e|
    error!({ errors: [Entities::ErrorEntity.represent({ title: 'Not Found',
                                                        detail: 'Item not found with given identifier' })] }, 404)
  end
  rescue_from ForbiddenError do |_e|
    error!({ errors: [Entities::ErrorEntity.represent({ title: 'Forbidden',
                                                        detail: 'Access is forbidden' })] }, 403)
  end
  rescue_from :all do |e|
    error!({ errors: [Entities::ErrorEntity.represent({ title: 'Internal Server Error',
                                                        detail: e.message })] }, 500)
  end

  helpers do
    def protect_from_forgery
      raise ForbiddenError.new if headers['X-CSRF-Token'].blank?
      raise ForbiddenError.new unless cookies['CSRF-TOKEN'] == headers['X-CSRF-Token']
    end
  end

  mount V0::Base
  mount Utilities

  add_swagger_documentation \
    mount_path: '/openapi',
    info: {
      title: 'Lighthouse Consumer Management Service',
      description: 'Source of truth for information regarding a Lighthouse consumer',
      contact_url: 'https://github.com/department-of-veterans-affairs/lighthouse-platform-backend'
    }
end
