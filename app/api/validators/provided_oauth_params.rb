# frozen_string_literal: true

module Validators
  class ProvidedOauthParams < Grape::Validations::Validators::Base
    def validate_param!(attr_name, params)
      return unless @option
      return if params[attr_name].blank?
      return if params[attr_name].is_a?(String)

      params[attr_name].each { |api| validate_oauth_params!(api, params) }
    end

    private

    def validate_oauth_params!(api, params)
      validate_acg_oauth_params!(params) if api.auth_type == 'acg'
      validate_ccg_oauth_params!(params) if api.auth_type == 'ccg'
    end

    def validate_acg_oauth_params!(params)
      return if params[:oAuthApplicationType].present? && params[:oAuthRedirectURI].present?

      raise Grape::Exceptions::Validation.new(params: %w[oAuthApplicationType oAuthRedirectURI],
                                              message: 'missing required oAuth values')
    end

    def validate_ccg_oauth_params!(params)
      if params[:oAuthPublicKey].blank?
        raise Grape::Exceptions::Validation.new(params: %w[oAuthPublicKey],
                                                message: 'missing required oAuth value')
      end

      begin
        jwk = JSON.parse(params[:oAuthPublicKey])
      rescue JSON::ParserError
        return # this will get caught and responded to by grape's built-in validator
      end

      begin
        JWT::JWK.import(jwk)
      rescue ArgumentError
        raise Grape::Exceptions::Validation.new(params: %w[oAuthPublicKey],
                                                message: 'invalid OAuth public key')
      end
    end
  end
end
