# frozen_string_literal: true

require 'rails_helper'

describe Utilities, type: :request do
  describe 'Running database seeds' do
    it 'creates new api records through database seed file' do
      expect do
        post '/platform-backend/utilities/database/seed-requests'
      end.to change(Api, :count).by(14)
    end
  end

  describe 'Deleting APIs' do
    it 'discards all apis' do
      create(:api, name: 'Claims API')

      delete '/platform-backend/utilities/apis'
      expect(response.status).to eq(200)
    end
  end

  describe 'Migrating Consumers' do
    it 'initializes migration of consumers into new structure' do
      post '/platform-backend/utilities/database/consumer-migration-requests'
      expect(response.status).to eq(201)
    end
  end

  describe 'Deleting Consumers' do
    it 'discards all users/consumers' do
      user = create(:user)
      create(:consumer, user_id: user.id)

      delete '/platform-backend/utilities/consumers'
      expect(response.status).to eq(200)
    end
  end
end



