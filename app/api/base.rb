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
  rescue_from ApiValidationError do |_e|
    error!({ errors: ['Invalid API list for consumer'] }, 422)
  end
  rescue_from :all do |e|
    error!({ errors: [e.message] }, 500)
  end

  helpers do
    def protect_from_forgery
      return unless Flipper.enabled? :protect_from_forgery

      Rails.logger.info "headers['X-Csrf-Token'] is blank" if headers['X-Csrf-Token'].blank?
      raise "headers['X-Csrf-Token'] is blank" if headers['X-Csrf-Token'].blank?

      result = /.*CSRF-TOKEN=(?<csrf_token>.*?)(?<end_character>;|$).*/.match(@env['HTTP_COOKIE'])
      csrf_token = result.present? ? result.named_captures['csrf_token'] : nil
      unless csrf_token == headers['X-Csrf-Token']
        Rails.logger.info "#{csrf_token} does not equal #{headers['X-Csrf-Token']}"
        raise "#{csrf_token} does not equal #{headers['X-Csrf-Token']}, #{@env['HTTP_COOKIE']}"
      end
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
