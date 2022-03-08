# frozen_string_literal: true

require 'rails_helper'

describe V0::Providers, type: :request do
  let!(:api_environments) { create_list(:api_environment, 3) }

  describe 'returns list of api providers' do
    it 'returns all apis in a form the developer-portal knows how to deal with' do
      get '/platform-backend/v0/providers/transformations/legacy'
      expect(response.code).to eq('200')

      expect(JSON.parse(response.body).count).to eq(3)
    end

    it 'returns all apis' do
      get '/platform-backend/v0/providers'
      expect(response.code).to eq('200')

      expect(JSON.parse(response.body).count).to eq(3)
    end
  end

  describe 'returns list of api provider release notes' do
    it 'returns all release notes for an api' do
      get "/platform-backend/v0/providers/#{api_environments.first.api.name}/release-notes"
      expect(response.code).to eq('200')

      expect(JSON.parse(response.body).count).to eq(3)
    end

    it 'raises exception due to not finding api provider' do
      get '/platform-backend/v0/providers/invalid-provider-name-here/release-notes'
      expect(response.code).to eq('404')
    end
  end

  describe 'appends release note to providers release notes' do
    it 'appends release note' do
      expect do
        post "/platform-backend/v0/providers/#{api_environments.first.api.name}/release-notes",
             params: { content: 'release-note content here' }
        expect(response.code).to eq('201')
      end.to change(ApiReleaseNote, :count).by(1)
    end

    it 'raises exception due to not finding api provider' do
      post '/platform-backend/v0/providers/invalid-provider-name-here/release-notes',
           params: { content: 'release-note content here' }
      expect(response.code).to eq('404')
    end
  end
end
