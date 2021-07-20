# frozen_string_literal: true

require 'rails_helper'

describe ConsumersController, type: :request do
  describe 'creating a consumer' do
    claims_api = FactoryBot.create(:api, name: 'Claims API', api_ref: 'claims')
    forms_api = FactoryBot.create(:api, name: 'Forms API', api_ref: 'vaForms')
    appeals_api = FactoryBot.create(:api, name: 'Appeals API', api_ref: 'decision_reviews')

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

    before do
      forms_api
      claims_api
      appeals_api
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

    it 'updates a users APIs' do
      user = FactoryBot.create(:user, email: 'test@email.com')
      consumer = FactoryBot.create(:consumer, user: user)
      consumer.apis << claims_api
      consumer.apis << forms_api
      consumer.save
      valid_params[:user][:consumer_attributes][:apis_list] = 'decision_reviews'
      post '/consumers', params: valid_params
      expect(Consumer.last.apis.map(&:name)).to eq(['Claims API', 'Forms API', 'Appeals API'])
    end

    it 'updates consumer_api_assignments if new values are added' do
      pending
    end

    it 'does not delete a consumer_api_assignment' do
      pending
    end
  end
end
