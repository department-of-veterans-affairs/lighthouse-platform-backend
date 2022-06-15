# frozen_string_literal: true

require 'rails_helper'

describe V0::Providers, type: :request do
  let!(:api_environments) { create_list(:api_environment, 3) }

  describe 'returns list of api providers' do
    it 'returns all apis in a form the developer-portal knows how to deal with' do
      Rails.application.load_tasks if Rake.application.tasks.blank?
      VCR.use_cassette('urlhaus/malicious_urls_200', match_requests_on: [:method]) do
        Rake::Task['db:seed'].execute
      end

      get '/platform-backend/v0/providers/transformations/legacy'
      expect(response.code).to eq('200')

      expect(JSON.parse(response.body).count).to eq(7)
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
  
  describe 'allows posts to create providers' do
    let(:provider)  { build(:provider) }
    before do
      create(:api_category)
    end
    it 'creates a valid API' do
      expect do
        post '/platform-backend/v0/providers', params: provider
        expect(response.status).to eq(201)
      end.to change(Api, :count).by 1
    end
    
    it 'provides an error when supplied invalid information' do
      provider['name'] = ''
      post '/platform-backend/v0/providers', params: provider
      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)['errors'].length).to eq(1)
    end
  end

  describe 'enforces auth for non dev portal routes' do
    before do
      Flipper.enable :validate_token
    end

    after do
      Flipper.disable :validate_token
    end

    it 'retrieves consumers with access_token' do
      VCR.use_cassette('okta/access_token_200', match_requests_on: [:method]) do
        get '/platform-backend/v0/providers', params: {},
                                              headers: { Authorization: 'Bearer t0k3n' }
        expect(response.status).to eq(200)
      end
    end
  end
end
