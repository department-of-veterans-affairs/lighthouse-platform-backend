# frozen_string_literal: true

class Base < Grape::API
  format :json
  rescue_from Grape::Exceptions::ValidationErrors do |e|
    error!({ errors: e.message.split(',') }, 400)
  end
  rescue_from Grape::Exceptions::Validation do |e|
    error!({ errors: e.message.split(',') }, 400)
  end
  rescue_from ActiveRecord::RecordNotFound do |_e|
    error!({ errors: ['Item not found with given identifier'] }, 404)
  end
  rescue_from ForbiddenError do |_e|
    error!({ errors: ['Access is forbidden'] }, 403)
  end
  rescue_from :all do |e|
    error!({ errors: [e.message] }, 500)
  end

  helpers do
    def protect_from_forgery
      return unless Flipper.enabled? :protect_from_forgery

      raise ForbiddenError if headers['X-Csrf-Token'].blank?
      raise ForbiddenError unless cookies['CSRF-TOKEN'] == headers['X-Csrf-Token']
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
