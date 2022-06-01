# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token, only: [:not_found]

  def not_found
    render json: {
      title: 'Not Found',
      detail: 'Route not found'
    }, status: :not_found
  end
end
