# frozen_string_literal: true

require 'rails_helper'

describe V0::Providers, type: :request do
  let!(:api_environments) { create_list(:api_environment, 3) }
  let(:provider_api) { create(:api) }

  describe 'returns list of api providers' do
    it 'returns all apis' do
      get '/platform-backend/v0/providers'
      expect(response.code).to eq('200')

      expect(JSON.parse(response.body).count).to eq(3)
    end

    context 'filters when passed an auth_type' do
      before do
        create(:api_environment, :auth_server_access_key_specific)
      end

      it 'works with oauth specific' do
        get '/platform-backend/v0/providers?authType=oauth/acg'

        expect(JSON.parse(response.body).count).to eq(1)
      end

      it 'works with apikeys' do
        get '/platform-backend/v0/providers?authType=apikey'

        expect(JSON.parse(response.body).count).to eq(3)
      end
    end

    context 'can be specified for a provider' do
      before do
        provider_api
      end

      it 'retrieves the respective API details' do
        get "/platform-backend/v0/providers/#{provider_api.name}"
        expect(JSON.parse(response.body)['authTypes']).to match_array(['apikey', 'oauth/acg', 'oauth/ccg'])
      end
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

    it 'discards existing release note and appends new release note' do
      original = ApiReleaseNote.create(api_metadatum_id: api_environments.first.api.api_metadatum.id,
                                       date: Time.zone.now.to_date.strftime('%Y-%m-%d'),
                                       content: 'release-note content here')

      expect do
        post "/platform-backend/v0/providers/#{api_environments.first.api.name}/release-notes",
             params: { content: 'release-note content *fix* here' }
        expect(response.code).to eq('201')
      end.to change(ApiReleaseNote, :count).by(1)

      expect(ApiReleaseNote.find(original.id).discarded_at.present?).to be(true)
    end
  end

  describe 'allows posts to create providers' do
    let(:provider) { build(:provider) }

    before do
      create(:api_category)
    end

    it 'creates a valid API' do
      expect do
        post '/platform-backend/v0/providers', params: provider
        expect(response).to have_http_status(:created)
      end.to change(Api, :count).by 1
    end

    it 'provides an error when supplied invalid information' do
      provider['name'] = ''
      post '/platform-backend/v0/providers', params: provider
      expect(response).to have_http_status(:bad_request)
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
      VCR.use_cassette('kong/access_token_200', match_requests_on: [:method]) do
        get '/platform-backend/v0/providers', params: {},
                                              headers: { Authorization: 'Bearer t0k3n' }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'allows third party applications to request lone signups for a provider' do
    context 'for api keys' do
      before do
        provider_api
      end

      it 'updates or creates a consumer with the requested APIs' do
        expect do
          params = { email: 'test@example.com', firstName: 'Bon', lastName: 'Jovi', termsOfService: true }
          post "/platform-backend/v0/providers/#{provider_api.name}/auth-types/apikey/consumers", params: params
        end.to change(ConsumerAuthRef, :count).by 1
      end
    end

    context 'provides singular acg and ccg oauth signups' do
      let(:api) { create(:api, :with_auth_server) }
      let(:params) do
        { email: 'test@example.com', firstName: 'Bon', lastName: 'Jovi', termsOfService: true, oAuthApplicationType: 'web',
          oAuthRedirectUri: 'http://localhost:3000/callback',
          oAuthPublicKey: {
            kid: nil,
            kty: 'RSA',
            e: 'AQAB',
            use: nil,
            n: '2Fb4_D4-RSjvl11txu-0s9bThk8hTo2SJauTRrS9N7piFlpGi6PBql3KzLmEu_T36YMbmTjDRPyybEEBD_XkEDuNdWSQph5Da7atfFM04IW5WH3MGPuvmaH6WpZB4Li5qESTFaMk0677uCDvOLcJmfa8bzunvbtlB4U-1WLjtDBODWiVpLlGEUofNQdX2MvTF9shtm-QqPk7K-a2Z36LrZpgcQBB1U8QtqexdaLrMgaoxmEbSgXGAc-uDkmQx1VOAsREozYZ9f1tASmOKGlxfVyBHcf6dePxq1cewpmrUfRTezky5A4K6v17uBYSpEols4ritWDRDymb7rFlUwxBjqdCjmtV18HiLIrgBNPQ2-5Jlnt-BCJg3lP_UG0r6cMO2DEtTkAkDcy4HzNuMQCrXn5ZL4kSUITrf9Mixny3vFn3aVcSNsCqLUSAfnpfRIz9oUUz5xI-FD9QsJJ1vneC8mfo-1lNaVRLNhn2t9VWY0kqhNNzS2HIktkZGzGv7gsB'
          }.to_json }
      end

      before do
        api
      end

      it 'works with acg' do
        VCR.use_cassette('okta/consumer_signup_200', match_requests_on: [:method]) do
          expect do
            post "/platform-backend/v0/providers/#{api.name}/auth-types/oauth/acg/consumers", params: params
          end.to change(ConsumerAuthRef, :count).by 1
        end
      end

      it 'works with ccg' do
        VCR.use_cassette('okta/consumer_signup_ccg_200', match_requests_on: [:method]) do
          expect do
            post "/platform-backend/v0/providers/#{api.name}/auth-types/oauth/ccg/consumers", params: params
          end.to change(ConsumerAuthRef, :count).by 1
        end
      end
    end
  end

  describe 'transformations legacy endpoint' do
    it 'returns all apis' do
      get '/platform-backend/v0/providers/transformations/legacy'
      expect(response.code).to eq('200')

      # 3 because of the 'create_list(:api_environment, 3)' at the top of this file
      expect(JSON.parse(response.body).count).to eq(3)
    end

    describe "it includes the new 'IA' fields" do
      it "includes the 'overviewPageContent' field" do
        get '/platform-backend/v0/providers/transformations/legacy'

        parsed_response = JSON.parse(response.body)
        first_category_key = parsed_response.keys[0]
        first_api = parsed_response[first_category_key]['apis'].first
        expect(first_api).to have_key('overviewPageContent')
      end

      it "includes the 'restrictedAccessDetails' field" do
        get '/platform-backend/v0/providers/transformations/legacy'

        parsed_response = JSON.parse(response.body)
        first_category_key = parsed_response.keys[0]
        first_api = parsed_response[first_category_key]['apis'].first
        expect(first_api).to have_key('restrictedAccessDetails')
      end

      it "includes the 'restrictedAccessToggle' field" do
        get '/platform-backend/v0/providers/transformations/legacy'

        parsed_response = JSON.parse(response.body)
        first_category_key = parsed_response.keys[0]
        first_api = parsed_response[first_category_key]['apis'].first
        expect(first_api).to have_key('restrictedAccessToggle')
      end

      it "includes the api 'urlSlug' field" do
        get '/platform-backend/v0/providers/transformations/legacy'

        parsed_response = JSON.parse(response.body)
        first_category_key = parsed_response.keys[0]
        first_api = parsed_response[first_category_key]['apis'].first
        expect(first_api).to have_key('urlSlug')
      end

      it "includes the api category 'urlSlug' field" do
        get '/platform-backend/v0/providers/transformations/legacy'

        parsed_response = JSON.parse(response.body)
        first_category_key = parsed_response.keys[0]
        first_category = parsed_response[first_category_key]
        expect(first_category).to have_key('urlSlug')
      end
    end
  end
end
