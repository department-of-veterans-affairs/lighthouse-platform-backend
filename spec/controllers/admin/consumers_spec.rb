# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::ConsumersController', type: :request do
  describe 'Migrating Consumers' do
    it 'initializes migration of consumers into new structure' do
      post '/platform-backend/admin/dashboard/consumers:migrate'
      expect(response.status).to eq(200)
    end
  end

  describe 'Deleting Consumers' do
    it 'discards all users/consumers' do
      user = FactoryBot.create(:user)
      FactoryBot.create(:consumer, user_id: user.id)

      post '/platform-backend/admin/dashboard/consumers/destroy_all'
      expect(response.status).to eq(302)
    end
  end
end
