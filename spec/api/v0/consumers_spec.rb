# frozen_string_literal: true

require 'rails_helper'

describe V0::Consumers, type: :request do
  describe 'accepts signups from dev portal' do
    let(:apply_base) { '/platform-backend/v0/consumers/applications' }
    let!(:claims_api) { FactoryBot.create(:api, name: 'Claims API', acl: 'claims_acl') }
    let!(:claims_api_ref) { FactoryBot.create(:api_ref, name: 'claims', api_id: claims_api.id) }
    let!(:forms_api) { FactoryBot.create(:api, name: 'Forms API', acl: 'vaForms_acl') }
    let!(:forms_api_ref) { FactoryBot.create(:api_ref, name: 'vaForms', api_id: forms_api.id) }
    let!(:oauth_api) { FactoryBot.create(:api, name: 'Oauth', auth_server_access_key: 'AUTHZ_SERVER_DEFAULT') }
    let!(:oauth_ref) { FactoryBot.create(:api_ref, name: 'oauth', api_id: oauth_api.id) }

    context 'when signup is successful' do
      let :signup_params do
        {
          apis: 'claims,vaForms,oauth',
          description: 'Signing up for Patti',
          email: 'doug@douglas.funnie.org',
          firstName: 'Douglas',
          lastName: 'Funnie',
          oAuthApplicationType: 'web',
          oAuthRedirectURI: 'http://localhost:3000/callback',
          organization: 'Doug',
          termsOfService: true
        }
      end

      it 'creates the respective user, consumer and apis via the apply page' do
        VCR.use_cassette('okta/consumer_signup_200', match_requests_on: [:method]) do
          post apply_base, params: signup_params
          expect(response.code).to eq('201')

          expect(User.count).to eq(1)
          expect(Consumer.count).to eq(1)
          expect(User.last.consumer.apis.count).to eq(3)
        end
      end
    end

    context 'when oauth arguments are missing' do
      let :signup_params do
        {
          apis: 'claims,vaForms,oauth',
          description: 'Signing up for Patti',
          email: 'doug@douglas.funnie.org',
          firstName: 'Douglas',
          lastName: 'Funnie',
          organization: 'Doug',
          termsOfService: true
        }
      end

      it 'responds with bad request' do
        post apply_base, params: signup_params
        expect(response.code).to eq('400')
      end
    end

    context 'when oauth arguments are invalid' do
      let :signup_params do
        {
          apis: 'claims,vaForms,oauth',
          description: 'Signing up for Patti',
          email: 'doug@douglas.funnie.org',
          firstName: 'Douglas',
          lastName: 'Funnie',
          oAuthApplicationType: 'invalid-value',
          oAuthRedirectURI: 'http://localhost:3000/callback',
          organization: 'Doug',
          termsOfService: true
        }
      end

      it 'responds with bad request' do
        post apply_base, params: signup_params
        expect(response.code).to eq('400')
      end
    end

    context 'when signup raises an unexpected exception' do
      let :signup_params do
        {
          apis: 'claims,vaForms,oauth',
          description: 'Signing up for Patti',
          email: 'doug@douglas.funnie.org',
          firstName: 'Douglas',
          lastName: 'Funnie',
          oAuthApplicationType: 'web',
          oAuthRedirectURI: 'http://localhost:3000/callback',
          organization: 'Doug',
          termsOfService: true
        }
      end

      it 'responds with internal server error' do
        allow_any_instance_of(KongService).to receive(:consumer_signup).and_raise(StandardError)
        post apply_base, params: signup_params
        expect(response.code).to eq('500')
      end
    end
  end
end
