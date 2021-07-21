# frozen_string_literal: true

require 'rails_helper'

describe ConsumersController, type: :request do
  let :valid_params do
    {
      user: {
        email: 'origami@oregano.com',
        first_name: 'taco',
        last_name: 'burrito',
        organization: 'taco-burrito supply',
        consumer_attributes: {
          description: 'i like tacos',
          sandbox_gateway_ref: '123990a9df9012i10',
          sandbox_oauth_ref: '02h89fe8h8daf',
          apis_list: 'claims,vaForms'
        }
      }
    }
  end

  describe 'creating a consumer' do
    let(:claims_api) { FactoryBot.create(:api, name: 'Claims API', api_ref: 'claims') }
    let(:forms_api) { FactoryBot.create(:api, name: 'Forms API', api_ref: 'vaForms') }

    before do
      forms_api
      claims_api
    end

    it 'creates the user' do
      expect do
        post '/consumers', params: valid_params
      end.to change(User, :count).by(1)
    end

    it 'creates the consumer' do
      expect do
        post '/consumers', params: valid_params
      end.to change(Consumer, :count).by(1)
    end

    it 'builds a consumer_api_assigment to the consumer' do
      expect do
        post '/consumers', params: valid_params
      end.to change(ConsumerApiAssignment, :count).by(2)
    end

    it 'responds properly when user fails to save' do
      valid_params[:user][:first_name] = nil
      post '/consumers', params: valid_params
      rubyize_response = JSON.parse response.body
      expect(rubyize_response).to have_key('error')
      expect(rubyize_response['error'].first).to start_with('First name')
    end
  end

  describe 'Updating a consumer' do
    let(:appeals_api) { FactoryBot.create(:api, name: 'Appeals API', api_ref: 'decision_reviews') }
    let :update_params do
      {
        user: {
          email: 'origami@oregano.com',
          consumer_attributes: {
            apis_list: 'decision_reviews'
          }
        }
      }
    end

    before do
      appeals_api
    end

    it 'updates a users APIs' do
      user = FactoryBot.create(:user, email: 'origami@oregano.com')
      consumer = FactoryBot.create(:consumer, :with_apis, user_id: user.id)
      post '/consumers', params: update_params
      expect(consumer.apis.map(&:name).sort).to eq(['Appeals API', 'Claims API', 'Forms API'])
    end

    it 'does not duplicate assignments passed in again' do
      user = FactoryBot.create(:user, email: 'origami@oregano.com')
      consumer = FactoryBot.create(:consumer, :with_apis, user_id: user.id)
      valid_params[:user][:consumer_attributes][:apis_list] = 'va_forms'
      post '/consumers', params: valid_params
      expect(consumer.apis.map(&:name).sort).to eq(['Claims API', 'Forms API'])
    end

    it 'responds properly when consumer fails to update' do
      valid_params[:user][:consumer_attributes][:description] = nil
      post '/consumers', params: valid_params
      rubyize_response = JSON.parse response.body
      expect(rubyize_response).to have_key('error')
      expect(rubyize_response['error'].first).to start_with('Consumer description')
    end
  end
end
