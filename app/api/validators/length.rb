# frozen_string_literal: true

module Validators
  class Length < Grape::Validations::Validators::Base
    def validate_param!(attr_name, params)
      return if params[attr_name].blank?
      return if params[attr_name].length <= @option

      raise Grape::Exceptions::Validation.new params: [@scope.full_name(attr_name)],
                                              message: "must be at the most #{@option} characters long"
    end
  end
end
