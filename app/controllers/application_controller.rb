# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from StandardError, with: :render_error_response
  rescue_from ActionController::ParameterMissing, with: :render_param_missing_error_response

  def render_param_missing_error_response(error)
    render json: ErrorSerializer.render(error), status: :bad_request
  end

  def render_error_response(error)
    render json: ErrorSerializer.render(error), status: :internal_server_error
  end
end
