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

    context 'filtering users/consumers' do
      context 'by api and environment' do
        context "enforcing all-or-none for 'apiId' and 'environment' filters" do
          it "rejects the request if 'apiId' is present, but 'environment' isn't" do
            get '/platform-backend/utilities/consumers?apiId=1'
            expect(response).to have_http_status(:bad_request)
          end

          it "rejects the request if 'environment' is present, but 'apiId' isn't" do
            get '/platform-backend/utilities/consumers?environment=sandbox'
            expect(response).to have_http_status(:bad_request)
          end
        end

        context "enforcing allowed values for 'environment'" do
          context "when 'environment' is anything other than 'sandbox' or 'production'" do
            it 'rejects the request' do
              get '/platform-backend/utilities/consumers?apiId=1&environment=blah'
              expect(response).to have_http_status(:bad_request)
            end
          end
        end

        it 'returns only matching users/consumers' do
          temp_user = create(:user)
          temp_consumer = create(:consumer, :with_production_apis, user_id: temp_user.id)
          temp_api = temp_consumer.api_environments.first.api

          get "/platform-backend/utilities/consumers?apiId=#{temp_api.id}&environment=production"

          json_output = JSON.parse(response.body)
          expect(json_output.count).to be(1)
          expect(json_output.first['email']).to eq(temp_user.email)
        end

        context 'when the user/consumer has been discarded' do
          it 'does not return the discarded user/consumer' do
            temp_user = create(:user)
            temp_consumer = create(:consumer, :with_production_apis, user_id: temp_user.id)
            temp_api = temp_consumer.api_environments.first.api
            temp_user.discard

            get "/platform-backend/utilities/consumers?apiId=#{temp_api.id}&environment=production"

            json_output = JSON.parse(response.body)
            expect(json_output.count).to be(0)
          end
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

  describe 'address validation API' do
    let(:address_validation_candidate_params) do
      {
        requestAddress: {
          addressLine1: "1700 Epcot Resorts Blvd",
          addressLine2: "",
          addressLine3: "",
          city: "Lake Buena Vista",
          zipCode5: "32830",
          zipCode4: "",
          internationalPostalCode: "",
          addressPOU: "RESIDENCE/CHOICE",
          stateProvince: {
            name: "Florida",
            code: "FL"
          },
          requestCountry: {
            countryName: "United States of America",
            countryCode: "USA"
          }
        }
      }
    end

    it 'returns the result from the Address Validation API v2 /candidate endpoint' do
      VCR.use_cassette('address_validation/candidate_v2_200', match_requests_on: [:method]) do
        post '/platform-backend/utilities/address-validation/candidate', params: address_validation_candidate_params
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
