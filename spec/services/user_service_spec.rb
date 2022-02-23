# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserService do
  let(:subject) { UserService.new }
  let(:user) { create(:user, first_name: 'Tony', last_name: 'Stark', email: 'tony@stark.com') }
  let(:okta_ref) { '0kt4-rul3s' }
  let(:gateway_ref) { 'l3g1t-1d' }
  let(:consumer) do
    create(:consumer, user: user, sandbox_gateway_ref: gateway_ref, sandbox_oauth_ref: okta_ref)
  end
  let(:api_environments) { create_list(:api_environment, 3) }
  let(:api_ref_one) { api_environments.first.api.api_ref.name }
  let(:api_ref_two) { api_environments.second.api.api_ref.name }
  let :consumer_params do
    {
      user: {
        email: 'tony@stark.com',
        first_name: 'Tony',
        last_name: 'Stark',
        consumer_attributes: {
          description: 'Design all the things',
          organization: 'Stark Enterprises',
          sandbox_gateway_ref: gateway_ref,
          sandbox_oauth_ref: okta_ref,
          apis_list: api_ref_one,
          tos_accepted: true
        }
      }
    }
  end

  let :new_consumer_params do
    {
      user: {
        email: 'stephan@strange.com',
        first_name: 'Stephen',
        last_name: 'Strange',
        consumer_attributes: {
          description: 'do all the magic',
          organization: 'magic people',
          sandbox_gateway_ref: gateway_ref,
          sandbox_oauth_ref: okta_ref,
          apis_list: api_ref_one,
          tos_accepted: true
        }
      }
    }
  end

  before do
    consumer
  end

  describe 'constructs a user' do
    it 'creates user for new signup' do
      expect do
        UserService.new.construct_import(new_consumer_params, 'sandbox')
      end.to change(User, :count).by(1)
    end

    it 'adds consumer api assignments for a new signup' do
      expect do
        UserService.new.construct_import(new_consumer_params, 'sandbox')
      end.to change(Consumer, :count).by(1)
    end

    it 'assigns apis for new signups' do
      expect do
        UserService.new.construct_import(new_consumer_params, 'sandbox')
      end.to change(ConsumerApiAssignment, :count).by(1)
    end

    it 'updates first and last name when email is the same' do
      consumer_params[:user][:first_name] = 'Sorcerer'
      consumer_params[:user][:last_name] = 'Supreme'
      UserService.new.construct_import(consumer_params, 'sandbox')
      reloaded = User.find_by(email: consumer_params[:user][:email])
      expect(reloaded.first_name).to eq('Sorcerer')
      expect(reloaded.last_name).to eq('Supreme')
    end

    it 'appends new apis when given an additional signup with new api(s)' do
      UserService.new.construct_import(consumer_params, 'sandbox')
      consumer_params[:user][:consumer_attributes][:apis_list] = api_ref_two
      UserService.new.construct_import(consumer_params, 'sandbox')
      reloaded = User.find_by(email: consumer_params[:user][:email])
      expect(reloaded.consumer.apis.collect { |api| api.api_ref.name }.sort).to eq([api_ref_one, api_ref_two].sort)
    end

    it 'apis are not removed on a new signup with same email' do
      UserService.new.construct_import(consumer_params, 'sandbox')
      consumer_params[:user][:consumer_attributes][:apis_list] = api_ref_one
      UserService.new.construct_import(consumer_params, 'sandbox')
      reloaded = User.find_by(email: consumer_params[:user][:email])
      expect(reloaded.consumer.apis.collect { |api| api.api_ref.name }.sort).to eq([api_ref_one])
    end

    it 'does not reset the kong id if new oauth only signup' do
      consumer_params[:user][:consumer_attributes][:sandbox_gateway_ref] = nil
      UserService.new.construct_import(consumer_params, 'sandbox')
      reloaded = User.find_by(email: consumer_params[:user][:email])
      expect(reloaded.consumer.sandbox_gateway_ref).to eq('l3g1t-1d')
    end

    it 'does not reset the okta id if new key auth only signup' do
      consumer_params[:user][:consumer_attributes][:sandbox_oauth_ref] = nil
      UserService.new.construct_import(consumer_params, 'sandbox')
      reloaded = User.find_by(email: consumer_params[:user][:email])
      expect(reloaded.consumer.sandbox_oauth_ref).to eq('0kt4-rul3s')
    end

    it 'does update the kong id to the most current signups kong id' do
      consumer_params[:user][:consumer_attributes][:sandbox_gateway_ref] = 'm@rk6'
      UserService.new.construct_import(consumer_params, 'sandbox')
      reloaded = User.find_by(email: consumer_params[:user][:email])
      expect(reloaded.consumer.sandbox_gateway_ref).to eq('m@rk6')
    end

    it 'does update the okta id to the most current signups okta id' do
      consumer_params[:user][:consumer_attributes][:sandbox_oauth_ref] = 'm@rk6'
      UserService.new.construct_import(consumer_params, 'sandbox')
      reloaded = User.find_by(email: consumer_params[:user][:email])
      expect(reloaded.consumer.sandbox_oauth_ref).to eq('m@rk6')
    end
  end
end
