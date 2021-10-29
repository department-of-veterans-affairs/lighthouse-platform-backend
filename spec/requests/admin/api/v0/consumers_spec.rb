# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Api::V0::Consumers', type: :request do
  describe 'Migrating Consumers' do
    it 'initializes migration of consumers into new structure' do
      post '/platform-backend/admin/api/v0/consumers:migrate'
      expect(response.status).to eq(200)
    end
  end

  describe 'Deleting Consumers' do
    it 'discards all users/consumers' do
      post '/platform-backend/admin/api/v0/consumers/destroy_all'
      expect(response.status).to eq(302)
    end
  end
end
