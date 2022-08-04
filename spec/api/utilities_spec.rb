# frozen_string_literal: true

require 'rails_helper'

describe Utilities, type: :request do
  describe 'APIs' do
    before do
      create(:api, :with_api_environment)
    end

    it 'gets all apis' do
      get '/platform-backend/utilities/apis'
      expect(response).to have_http_status(:ok)
    end

    it 'provides a list of api categories' do
      get '/platform-backend/utilities/apis/categories'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'consumers' do
    before do
      user = create(:user)
      create(:consumer, user_id: user.id)
    end

    it 'gets all users/consumers' do
      get '/platform-backend/utilities/consumers'
      expect(response).to have_http_status(:ok)
    end

    context 'allows exporting consumers' do
      before do
        create(:api, :with_r34l_auth_server)
      end

      it 'and builds an export list' do
        VCR.use_cassette('utilities/export_200', match_requests_on: [:method]) do
          get '/platform-backend/utilities/consumers/export?environment=sandbox'
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['list'].length).to eq(2)
        end
      end
    end

    it 'gets weekly signups for consumers' do
      get '/platform-backend/utilities/consumers/signups-report/week'
      expect(response).to have_http_status(:ok)
    end

    it 'gets monthly signups for consumers' do
      get '/platform-backend/utilities/consumers/signups-report/month'
      expect(response).to have_http_status(:ok)
    end

    it 'gets unknown consumers in kong' do
      get '/platform-backend/utilities/kong/environments/sandbox/unknown-consumers'
      expect(response).to have_http_status(:ok)
    end

    it 'gets unknown applications in okta' do
      VCR.use_cassette('okta/list_applications_200', match_requests_on: [:method]) do
        get '/platform-backend/utilities/okta/environments/sandbox/unknown-applications'
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'lpb signups' do
    let(:signup_params) do
      build(:sandbox_signup_request, apis: 'ccg/lpb', environment: 'production', termsOfService: true,
                                     oAuthPublicKey: { yep: 'th1s-15-r34l' })
    end

    before do
      create(:api, :with_lpb_ref)
    end

    it 'allows signup access via utilities' do
      VCR.use_cassette('okta/consumer_signup_ccg_200', match_requests_on: [:method]) do
        post '/platform-backend/utilities/okta/lpb/applications', params: signup_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['apis']).to eq('lpb')
      end
    end
  end
end
