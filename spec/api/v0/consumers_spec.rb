# frozen_string_literal: true

require 'rails_helper'

describe V0::Consumers, type: :request do
  let(:production_request_base) { '/platform-backend/v0/consumers/production-requests' }
  let(:production_request_params) { build(:production_access_request) }
  let(:apply_base) { '/platform-backend/v0/consumers/applications' }
  let :signup_params do
    {
      apis: "#{api_ref_one},#{api_ref_two},#{api_ref_three},ccg/#{api_ref_three}",
      description: 'Signing up for Patti',
      email: 'doug@douglas.funnie.org',
      firstName: 'Douglas',
      lastName: 'Funnie',
      oAuthApplicationType: 'web',
      oAuthRedirectURI: 'http://localhost:3000/callback',
      oAuthPublicKey: { kty: 'RSA', n: 'key-value-here', e: 'AQAB' }.to_json,
      organization: 'Doug',
      termsOfService: true
    }
  end
  let(:api_environments) { create_list(:api_environment, 3) }
  let(:api_ref_one) { api_environments.first.api.api_ref.name }
  let(:api_ref_two) { api_environments.second.api.api_ref.name }
  let(:api_ref_three) { api_environments.last.api.api_ref.name }

  before do
    api_environments
    api = Api.last
    api.update!(auth_server_access_key: 'AUTHZ_SERVER_DEFAULT')
    api.update!(acl: nil)
  end

  describe 'lists consumers' do
    let(:user) { create(:user) }
    let(:consumer) { create(:consumer, user_id: user.id) }

    before do
      consumer
    end

    it 'that are kept' do
      get '/platform-backend/v0/consumers'
      first_consumer = JSON.parse(response.body).first
      expect(response.status).to eq(200)
      expect(first_consumer['id']).to eq(consumer.id)
      expect(first_consumer['email']).to eq(consumer.user.email)
    end

    context 'accepts an optional subscribe param' do
      it 'filters when provided subscribed' do
        get '/platform-backend/v0/consumers?subscribed=true'
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body).length).to eq(0)
      end

      it 'does not filter when provided =false' do
        get '/platform-backend/v0/consumers?subscribed=false'
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body).length).to eq(1)
      end

      it 'returns 400 when provided unsuitable value' do
        get '/platform-backend/v0/consumers?subscribed=tacos'
        expect(response.status).to eq(400)
      end
    end
  end

  describe 'accepts signups from dev portal' do
    context 'when signup is successful' do
      it 'creates the respective user, consumer and apis via the apply page' do
        VCR.use_cassette('okta/consumer_signup_200', match_requests_on: [:method]) do
          VCR.use_cassette('okta/consumer_signup_ccg_200', match_requests_on: [:method]) do
            post apply_base, params: signup_params
            expect(response.code).to eq('201')

            expect(User.count).to eq(1)
            expect(Consumer.count).to eq(1)
            expect(User.last.consumer.apis.count).to eq(3)
          end
        end
      end

      context 'with send_emails flag enabled' do
        before do
          Flipper.enable :send_emails

          api_environment = create(:api_environment)
          api_ref = api_environment.api.api_ref
          api_ref.name = 'addressValidation'
          api_ref.save!
        end

        after do
          Flipper.disable :send_emails
        end

        it 'sends va_profile_distribution an email if addressValidation is included' do
          signup_params[:apis] = 'addressValidation'
          consumer_email = double
          va_profile_email = double
          allow(SandboxMailer).to receive(:consumer_sandbox_signup).and_return(consumer_email)
          allow(SandboxMailer).to receive(:va_profile_sandbox_signup).and_return(va_profile_email)
          expect(consumer_email).to receive(:deliver_later)
          expect(va_profile_email).to receive(:deliver_later)
          post apply_base, params: signup_params
        end
      end

      context 'with send_slack_signup flag enabled' do
        before do
          Flipper.enable :send_slack_signup
        end

        after do
          Flipper.disable :send_slack_signup
        end

        it 'sends slack signup message' do
          signup_params[:apis] = api_ref_one
          signup_params[:oAuthApplicationType] = nil
          signup_params[:oAuthRedirectURI] = nil
          signup_params[:oAuthPublicKey] = nil

          expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
          post apply_base, params: signup_params
        end
      end

      context 'with protect_from_forgery flag enabled' do
        before do
          Flipper.enable :protect_from_forgery
        end

        after do
          Flipper.disable :protect_from_forgery
        end

        context 'when no x-csrf-token provided' do
          it 'responds with forbidden' do
            post apply_base, params: signup_params
            expect(response.code).to eq('403')
          end
        end

        context 'when an invalid x-csrf-token is provided' do
          it 'responds with forbidden' do
            post apply_base, params: signup_params, headers: { 'X-Csrf-Token': 'testing123' }
            expect(response.code).to eq('500')
          end
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

    context 'when invalid api is passed' do
      it 'responds with bad request' do
        signup_params[:apis] = 'invalid-api-here'
        post apply_base, params: signup_params
        expect(response.code).to eq('400')
      end
    end

    context 'when invalid auth_type is passed' do
      it 'responds with bad request' do
        signup_params[:apis] = "invalid-auth-type/#{api_ref_one}"
        post apply_base, params: signup_params
        expect(response.code).to eq('400')
      end
    end

    context 'when signup raises an unexpected exception' do
      it 'responds with internal server error' do
        allow_any_instance_of(Kong::SandboxService).to receive(:consumer_signup).and_raise(StandardError)
        post apply_base, params: signup_params
        expect(response.code).to eq('500')
      end
    end

    context 'when url is malicious' do
      it 'responds with bad request' do
        signup_params[:oAuthRedirectURI] = create(:malicious_url).url
        post apply_base, params: signup_params
        expect(response.code).to eq('400')
      end
    end
  end

  describe 'when flipper is disabled' do
    it 'fails to hit the sandbox mailer' do
      expect(SandboxMailer).not_to receive(:consumer_sandbox_signup)
      expect(SandboxMailer).not_to receive(:va_profile_sandbox_signup)
      post apply_base, params: signup_params
    end

    it 'fails to hit the production mailer' do
      expect(ProductionMailer).not_to receive(:consumer_production_access)
      expect(ProductionMailer).not_to receive(:support_production_access)
      post production_request_base, params: production_request_params
    end
  end

  describe 'enforces auth for non dev portal routes' do
    before do
      Flipper.enable :validate_token
    end

    after do
      Flipper.disable :validate_token
    end

    it 'receives unauthorized without respective token' do
      get '/platform-backend/v0/consumers'
      expect(response.status).to eq(401)
    end

    it 'receives unauthorized with an invalid token' do
      VCR.use_cassette('okta/access_token_invalid', match_requests_on: [:method]) do
        get '/platform-backend/v0/consumers', params: {}, headers: { Authorization: 'Bearer t0t4l1y-r34l' }
        expect(response.status).to eq(401)
      end
    end

    it 'receives forbidden with incorrect scopes' do
      VCR.use_cassette('okta/access_token_200', match_requests_on: [:method]) do
        get '/platform-backend/v0/consumers', params: {}, headers: { Authorization: 'Bearer t0k3n' }
        expect(response.status).to eq(403)
      end
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

  describe 'consumer statistics api' do
    let(:user) { create(:user) }
    let(:consumer) { create(:consumer, :with_sandbox_ids, user: user) }

    before do
      consumer
    end

    it 'returns a successful first call' do
      get "/platform-backend/v0/consumers/#{consumer[:id]}/statistics"
      expect(response.code).to eq('200')

      expect(response.body).to include('July 03, 2015')
    end
  end

  describe 'when promoted to the production environment' do
    let(:user) { create(:user) }
    let(:consumer) { create(:consumer, :with_autogenerated, user: user) }
    let(:api_ref) { consumer.apis.first.api_ref.name }
    let :params do
      {
        apis: api_ref
      }
    end
    let :bad_params do
      {
        apis: '1234'
      }
    end

    before do
      ApiEnvironment.find_or_create_by(api: consumer.apis.first,
                                       environment: Environment.find_or_create_by(name: 'production'))

      api_environment = create(:api_environment)
      api_ref = api_environment.api.api_ref
      api_ref.name = '1234'
      api_ref.save!
    end

    it 'promotes a consumer if given the appropriate sandbox APIs' do
      post "/platform-backend/v0/consumers/#{consumer[:id]}/promotion-requests", params: params

      expect(response.status).to eq(201)
      expect(consumer.api_environments.count).to eq(3)
    end

    it 'fails to promote if a consumer does not have sandbox access' do
      post "/platform-backend/v0/consumers/#{consumer[:id]}/promotion-requests", params: bad_params

      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)['errors']).to include('Invalid API list for consumer')
    end
  end
end
