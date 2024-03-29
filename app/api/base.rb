# frozen_string_literal: true

class Base < Grape::API
  use GrapeLogging::Middleware::RequestLogger, instrumentation_key: 'grape_key'

  format :json
  rescue_from Grape::Exceptions::ValidationErrors do |e|
    Rails.logger.warn "??? #{e.message}"
    error!({ errors: e.message.split(',') }, 400)
  end
  rescue_from Grape::Exceptions::Validation do |e|
    Rails.logger.warn "??? #{e.message}"
    error!({ errors: e.message.split(',') }, 400)
  end
  rescue_from ActiveRecord::RecordNotFound do |e|
    Rails.logger.warn "??? #{e.message}"
    error!({ errors: ['Item not found with given identifier'] }, 404)
  end
  rescue_from ForbiddenError do |e|
    Rails.logger.warn "??? #{e.message}"
    error!({ errors: ['Access is forbidden'] }, 403)
  end
  rescue_from AuthorizationError do |e|
    Rails.logger.warn "??? #{e.message}"
    error!({ errors: ['Unauthorized'] }, 401)
  end
  rescue_from ApiValidationError do |e|
    Rails.logger.warn "??? #{e.message}"
    error!({ errors: ['Invalid API list for consumer'] }, 422)
  end
  rescue_from :all do |e|
    Rails.logger.error "!!! #{e.message}\n#{e.backtrace}"
    error!({ errors: [e.message] }, 500)
  end

  helpers do
    def protect_from_forgery
      return unless Flipper.enabled? :protect_from_forgery

      raise ForbiddenError if headers['X-Csrf-Token'].blank?

      # TODO: Revert to ForbiddenError when CSRF protection through nginx is resolved
      unless cookies['CSRF-TOKEN'] == headers['X-Csrf-Token']
        raise "#{cookies['CSRF-TOKEN']} does not equal #{headers['X-Csrf-Token']}, #{cookies.to_json}"
      end
    end

    def validate_token(scope)
      return unless Flipper.enabled? :validate_token

      raise AuthorizationError if headers['Authorization'].nil?

      token = headers['Authorization'].match(/^Bearer (.*)$/)&.captures&.first
      raise AuthorizationError if token.nil?

      response = Okta::TokenValidationService.new.validate_token(token)

      raise AuthorizationError if response['errors'].present?

      validate_scope(scope, response)
    end

    def validate_scope(scope, response)
      response_scope = response.dig('data', 'attributes', 'scp')
      raise 'Auth scope not found' if response_scope.blank?
      raise ForbiddenError unless response_scope.include?(scope)
    end
  end

  mount V0::Base

  add_swagger_documentation \
    mount_path: '/openapi',
    info: {
      title: 'Lighthouse Platform Backend',
      description: 'Source of truth for information regarding a Lighthouse consumer',
      contact_url: 'https://github.com/department-of-veterans-affairs/lighthouse-platform-backend'
    }
end
