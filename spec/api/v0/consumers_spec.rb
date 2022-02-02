# frozen_string_literal: true

require 'rails_helper'

describe V0::Consumers, type: :request do
  describe 'accepts signups from dev portal' do
    let(:apply_base) { '/platform-backend/v0/consumers/applications' }
    let(:api_environments) { create_list(:api_environment, 3) }
    let(:api_ref_one) { api_environments.first.api.api_ref.name }
    let(:api_ref_two) { api_environments.second.api.api_ref.name }
    let(:api_ref_three) { api_environments.last.api.api_ref.name }
    let :signup_params do
      {
        apis: "#{api_ref_one},#{api_ref_two},#{api_ref_three}",
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

    before do
      api_environments.last.api.auth_server_access_key = 'AUTHZ_SERVER_DEFAULT'
      api_environments.last.api.acl = nil
    end

    context 'when signup is successful' do
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
      it 'responds with bad request' do
        signup_params[:oAuthApplicationType] = nil
        signup_params[:oAuthRedirectURI] = nil
        post apply_base, params: signup_params
        expect(response.code).to eq('400')
      end
    end

    context 'when oauth arguments are invalid' do
      it 'responds with bad request' do
        signup_params[:oAuthApplicationType] = 'invalid-value'
        post apply_base, params: signup_params
        expect(response.code).to eq('400')
      end
    end

    context 'when signup raises an unexpected exception' do
      it 'responds with internal server error' do
        allow_any_instance_of(KongService).to receive(:consumer_signup).and_raise(StandardError)
        post apply_base, params: signup_params
        expect(response.code).to eq('500')
      end
    end
  end
end
