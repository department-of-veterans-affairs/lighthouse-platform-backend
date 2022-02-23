# frozen_string_literal: true

require 'rails_helper'

describe V0::Consumers, type: :request do
  let(:production_request_base) { '/platform-backend/v0/consumers/production_request' }
  let(:production_request_params) { build(:production_access_request) }

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
      api_environments
      api = Api.last
      api.update!(auth_server_access_key: 'AUTHZ_SERVER_DEFAULT')
      api.update!(acl: nil)
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

  describe 'does not send email when flipper disabled' do
    it 'does not to hit the production mailer' do
      expect(ProductionMailer).not_to receive(:consumer_production_access)
      expect(ProductionMailer).not_to receive(:support_production_access)
      post production_request_base, params: production_request_params
    end
  end

  describe 'sends emails when prompted for production access' do
    after do
      Flipper.disable :send_emails
    end

    before do
      Flipper.enable :send_emails
    end

    context 'accepts successful requests' do
      it 'provides a successful response' do
        post production_request_base, params: production_request_params
        expect(response.code).to eq('204')
      end

      it 'sends an email to the consumer and support' do
        consumer_email = double
        support_email = double
        allow(ProductionMailer).to receive(:consumer_production_access).and_return(consumer_email)
        allow(ProductionMailer).to receive(:support_production_access).and_return(support_email)
        expect(consumer_email).to receive(:deliver_later)
        expect(support_email).to receive(:deliver_later)
        post production_request_base, params: production_request_params
      end
    end

    context 'fails if provided' do
      it 'an excessive description' do
        production_request_params[:veteranFacingDescription] = (0..425).map { rand(65..89).chr }.join
        post production_request_base, params: production_request_params
        expect(response.code).to eq('400')
      end

      it 'an incorrect phone number' do
        production_request_params[:phoneNumber] = '4444444444444444444'
        post production_request_base, params: production_request_params
        expect(response.code).to eq('400')
      end
    end
  end
end
