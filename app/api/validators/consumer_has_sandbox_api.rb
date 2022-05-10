# frozen_string_literal: true

module Validators
  class ConsumerHasSandboxApi < Grape::Validations::Validators::Base
    def validate_param!(attr_name, params)
      return unless @option
      return if params[attr_name].blank?
      return if params[attr_name].is_a?(String)

      consumer = Consumer.find(params[:consumerId])
      consumer_api_refs = consumer.apis.map(&:api_ref).map(&:name)
      params[attr_name].each do |api|
        next if consumer_api_refs.include?(api.api_ref.name)

        raise ApiValidationError
      end
    end
  end
end
