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

  describe 'APIs' do
    before do
      create(:api, name: 'Claims API')
    end

    it 'gets all apis' do
      get '/platform-backend/utilities/apis'
      expect(response.status).to eq(200)
    end

    it 'discards all apis' do
      delete '/platform-backend/utilities/apis'
      expect(response.status).to eq(200)
    end
  end

  it 'initializes migration of consumers into new structure' do
    post '/platform-backend/utilities/database/consumer-migration-requests'
    expect(response.status).to eq(201)
  end

  describe 'consumers' do
    before do
      user = create(:user)
      create(:consumer, user_id: user.id)
    end

    it 'gets all users/consumers' do
      get '/platform-backend/utilities/consumers'
      expect(response.status).to eq(200)
    end

    it 'discards all users/consumers' do
      delete '/platform-backend/utilities/consumers'
      expect(response.status).to eq(200)
    end
  end
end
