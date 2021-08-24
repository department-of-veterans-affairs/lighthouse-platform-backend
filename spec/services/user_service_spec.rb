# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserService do
  let(:subject) { UserService.new }
  let(:user) { FactoryBot.create(:user, first_name: 'Tony', last_name: 'Stark', email: 'tony@stark.com') }
  let(:okta_ref) { '0kt4-rul3s' }
  let(:gateway_ref) { 'l3g1t-1d' }
  let(:consumer) do
    FactoryBot.create(:consumer, :with_apis, user: user, sandbox_gateway_ref: gateway_ref, sandbox_oauth_ref: okta_ref)
  end
  let :consumer_params do
    {
      'email' => 'tony@stark.com',
      'firstName' => 'Tony',
      'lastName' => 'Stark',
      'description' => 'Design all the things.',
      'organization' => 'Stark Enterprises',
      'consumer_attributes' => {
        'apis_list' => 'claims'
      }
    }
  end

  let :new_consumer_params do
    {
      'email' => 'stephan@strange.com',
      'firstName' => 'Stephan',
      'lastName' => 'Strange',
      'description' => 'do all the magic',
      'organization' => 'magic people',
      'consumer_attributes' => {
        'apis_list' => 'claims'
      }
    }
  end

  before do
    user
    consumer
    gateway_ref
    okta_ref
    @claims_api = FactoryBot.create(:api, name: 'claims', api_ref: 'claims')
    FactoryBot.create(:api, name: 'va_forms', api_ref: 'va_forms')
  end

  describe 'constructs a user' do
    # it 'and builds the necessary user object for creation' do
    #   result = subject.construct_import(consumer, gateway_ref, okta_ref)
    #   expect(result[:user][:first_name]).to eq('Bruce')
    #   expect(result[:user][:consumer_attributes][:organization]).to eq('Wayne Enterprises')
    #   expect(result[:user][:consumer_attributes][:sandbox_oauth_ref]).to eq(okta_ref)
    # end

    it 'creates user for new signup' do
      expect do
        UserService.new.construct_import(new_consumer_params, gateway_ref, okta_ref)
      end.to change(User, :count).by(1)
    end

    it 'adds consumer aapi assignments fot a new signup' do
      expect do
        UserService.new.construct_import(new_consumer_params, gateway_ref, okta_ref)
      end.to change(Consumer, :count).by(1)
    end

    it 'assigns apis for new signups' do
      expect do
        UserService.new.construct_import(new_consumer_params, gateway_ref, okta_ref)
      end.to change(ConsumerApiAssignment, :count).by(1)
    end

    it 'updates fist last name when email is the same' do
      consumer_params['firstName'] = 'Sorcerer'
      consumer_params['lastName'] = 'Supreme'
      UserService.new.construct_import(consumer_params, gateway_ref, okta_ref)
      reloaded = User.find_by(email: consumer_params['email'])
      expect(reloaded.first_name).to eq('Sorcerer')
      expect(reloaded.last_name).to eq('Supreme')
    end

    it 'appends new apis when addition signup with new apis' do
      consumer_params['consumer_attributes']['apis_list'] = 'claims, va_forms'
      UserService.new.construct_import(consumer_params, gateway_ref, okta_ref)
      reloaded = User.find_by(email: consumer_params['email'])
      expect(reloaded.consumer.apis.map(&:api_ref)).to eq(%w[claims va_forms])
    end

    it 'apis are not removed on a new signup with same email' do
      consumer_params['consumer_attributes']['apis_list'] = 'va_forms'
      UserService.new.construct_import(consumer_params, gateway_ref, okta_ref)
      reloaded = User.find_by(email: consumer_params['email'])
      expect(reloaded.consumer.apis.map(&:api_ref)).to eq(%w[claims va_forms])
    end

    it 'does not reset the kong id if new oauth only signup' do
      gateway_ref = nil
      UserService.new.construct_import(consumer_params, gateway_ref, okta_ref)
      reloaded = User.find_by(email: consumer_params['email'])
      expect(reloaded.consumer.sandbox_gateway_ref).to eq('l3g1t-1d')
    end

    it 'does not reset the okta id if new key auth only signup' do
      okta_ref = nil
      UserService.new.construct_import(consumer_params, gateway_ref, okta_ref)
      reloaded = User.find_by(email: consumer_params['email'])
      expect(reloaded.consumer.sandbox_oauth_ref).to eq('0kt4-rul3s')
    end

    it 'does update the kong id to the most current signups kong id' do
      gateway_ref = 'm@rk6'
      UserService.new.construct_import(consumer_params, gateway_ref, okta_ref)
      reloaded = User.find_by(email: consumer_params['email'])
      expect(reloaded.consumer.sandbox_gateway_ref).to eq('m@rk6')
    end

    it 'does update the okta id to the most current signups okta id' do
      okta_ref = 'm@rk6'
      UserService.new.construct_import(consumer_params, gateway_ref, okta_ref)
      reloaded = User.find_by(email: consumer_params['email'])
      expect(reloaded.consumer.sandbox_oauth_ref).to eq('m@rk6')
    end
  end
end
