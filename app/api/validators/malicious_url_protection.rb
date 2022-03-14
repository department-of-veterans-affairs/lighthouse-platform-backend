# frozen_string_literal: true

module Validators
  class MaliciousUrlProtection < Grape::Validations::Validators::Base
    def validate_param!(attr_name, params)
      return unless @option
      return if MaliciousUrl.find_by(url: params[attr_name]).blank?

      raise Grape::Exceptions::Validation.new params: [@scope.full_name(attr_name)],
                                              message: "is an invalid url"
    end
  end
end
