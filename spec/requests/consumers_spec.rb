# frozen_string_literal: true

require 'rails_helper'

describe ConsumersController, type: :request do
  describe 'creating a consumer' do
    FactoryBot.create(:api, name: 'Claims API', api_ref: 'claims')
    FactoryBot.create(:api, name: 'Forms API', api_ref: 'vaForms')

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

    # add test to test api
    it 'builds a consumer_api_assigment to the consumer' do
      expect do
        post '/consumers', params: valid_params
      end.to change(ConsumerApiAssignment, :count).by(1)
    end
  end
end
