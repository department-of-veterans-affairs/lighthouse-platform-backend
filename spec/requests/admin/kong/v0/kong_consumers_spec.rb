# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Kong::V0::KongConsumersController', type: :request do
  describe 'GET index' do
    before do
      get '/platform-backend/admin/kong/v0/kong_consumers'
    end

    it 'returns a 200 status' do
      expect(response).to have_http_status(:success)
    end

    it 'displays a list of consumers' do
      expect(JSON.parse(response.body).count).to eq(2)
    end
  end

  describe 'GET show' do
    let(:kong_consumer) { 'lighthouse-consumer' }

    before do
      get "/platform-backend/admin/kong/v0/kong_consumers/#{kong_consumer}"
    end

    it 'returns a 200 status' do
      expect(response).to have_http_status(:success)
    end

    it 'displays the respective consumer' do
      expect((JSON.parse(response.body))['username']).to eq(kong_consumer)
    end
  end
end
