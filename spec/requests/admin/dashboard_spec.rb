# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Dashboards', type: :request do
  describe 'GET /platform-backend/admin/dashboard' do
    it 'return a redirect if the user is not signed in' do
      get '/platform-backend/admin/dashboard'
      expect(response).to have_http_status(:redirect)
    end
  end
end
