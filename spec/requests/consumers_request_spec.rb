# frozen_string_literal: true

require 'rails_helper'

describe ConsumersController, type: :request do
  base = '/platform-backend/consumers'
  let :valid_params do
    {
      user: {
        email: 'origami@oregano.com',
        first_name: 'taco',
        last_name: 'burrito',
        consumer_attributes: {
          description: 'i like tacos',
          organization: 'taco-burrito supply',
          sandbox_gateway_ref: '123990a9df9012i10',
          sandbox_oauth_ref: '02h89fe8h8daf',
          apis_list: 'claims,vaForms',
          tos_accepted: true
        }
      }
    }
  end

  describe 'creating a consumer' do
    let(:claims_api) { FactoryBot.create(:api, name: 'Claims API', acl: 'claims_acl') }
    let(:forms_api) { FactoryBot.create(:api, name: 'Forms API', acl: 'vaForms_acl') }
    let(:claims_api_ref) { FactoryBot.create(:api_ref, name: 'claims', api_id: claims_api.id) }
    let(:forms_api_ref) { FactoryBot.create(:api_ref, name: 'vaForms', api_id: forms_api.id) }

    before do
      claims_api
      forms_api
      claims_api_ref
      forms_api_ref
    end

    it 'creates the user' do
      expect do
        post base, params: valid_params
      end.to change(User, :count).by(1)
    end

    it 'creates the consumer' do
      expect do
        post base, params: valid_params
      end.to change(Consumer, :count).by(1)
    end

    it 'builds a consumer_api_assigment to the consumer' do
      expect do
        post base, params: valid_params
      end.to change(ConsumerApiAssignment, :count).by(2)
    end

    it 'responds properly when user fails to save' do
      valid_params[:user][:first_name] = nil
      post base, params: valid_params
      parsed = JSON.parse response.body
      expect(parsed).to have_key('error')
      expect(parsed['error'].first).to start_with('First name')
    end

    it 'creates a valid tos_accepted_at' do
      post base, params: valid_params
      expect(User.last.consumer.tos_accepted_at).to be < DateTime.now
      expect(User.last.consumer.tos_accepted_at).to be_a(ActiveSupport::TimeWithZone)
    end

    it 'raise an exception if TOS is not accepted' do
      valid_params[:user][:email] = 'new_user@user_of_the_new.com'
      valid_params[:user][:consumer_attributes][:tos_accepted] = false
      post base, params: valid_params
      parsed = JSON.parse response.body
      expect(parsed).to have_key('error')
      expect(parsed['error'].first).to eq('Consumer tos accepted is invalid.')
    end
  end

  describe 'Updating a consumer' do
    let(:appeals_api) { FactoryBot.create(:api, name: 'Appeals API', acl: 'decision_reviews') }
    let(:appeals_api_ref) { FactoryBot.create(:api_ref, name: 'decision_reviews', api_id: appeals_api.id) }
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
      appeals_api_ref
    end

    it 'updates a users APIs' do
      user = FactoryBot.create(:user, email: 'origami@oregano.com')
      consumer = FactoryBot.create(:consumer, :with_apis, user_id: user.id)
      post base, params: update_params
      expect(consumer.apis.map(&:name).sort).to eq(['Appeals API', 'Claims API', 'Forms API'])
    end

    it 'does not duplicate assignments passed in again' do
      user = FactoryBot.create(:user, email: 'origami@oregano.com')
      consumer = FactoryBot.create(:consumer, :with_apis, user_id: user.id)
      valid_params[:user][:consumer_attributes][:apis_list] = 'va_forms'
      post base, params: valid_params
      expect(consumer.apis.map(&:name).sort).to eq(['Claims API', 'Forms API'])
    end

    it 'responds properly when consumer fails to update' do
      valid_params[:user][:consumer_attributes][:description] = nil
      post base, params: valid_params
      parsed = JSON.parse response.body
      expect(parsed).to have_key('error')
      expect(parsed['error'].first).to start_with('Consumer description')
    end
  end
end
