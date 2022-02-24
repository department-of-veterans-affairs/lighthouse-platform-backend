# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def not_found
    render json: {
      title: 'Not Found',
      detail: 'Route not found'
    }, status: :not_found
  end
end
