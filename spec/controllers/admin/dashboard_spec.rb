# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::DashboardController', type: :request do
  describe 'GET /platform-backend/admin/dashboard with auth disabled' do
    before do
      ENV['ENABLE_GITHUB_AUTH'] = nil
    end

    it 'returns success' do
      get '/platform-backend/admin/dashboard'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /platform-backend/admin/dashboard with auth enabled' do
    before do
      ENV['ENABLE_GITHUB_AUTH'] = 'true'
    end

    after do
      ENV['ENABLE_GITHUB_AUTH'] = nil
    end

    it 'returns a redirect if the user is not signed in' do
      get '/platform-backend/admin/dashboard'
      expect(response).to have_http_status(:redirect)
    end

    it 'returns a success if the user is signed in' do
      user = User.create!(email: 'john@example.com', first_name: 'John', last_name: 'Smith', uid: '123545')
      sign_in user
      get '/platform-backend/admin/dashboard'
      expect(response).to have_http_status(:success)
    end
  end
end
