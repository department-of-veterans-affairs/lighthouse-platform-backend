# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Consumer, type: :model do
  subject do
    Consumer.new(description: test_description,
                 organization: 'Test User Organization',
                 tos_accepted_at: tos_test_time,
                 tos_version: 1,
                 sandbox_gateway_ref: auth_info[:sandbox][:gateway],
                 sandbox_oauth_ref: auth_info[:sandbox][:oauth],
                 prod_gateway_ref: auth_info[:prod][:gateway],
                 prod_oauth_ref: auth_info[:prod][:oauth],
                 user_id: parent[:id])
  end

  let(:parent) do
    create(:user,
           email: 'test_user@test_user_website.com',
           first_name: 'Test',
           last_name: 'User')
  end
  let(:test_description) { 'This is an in depth description.' }
  let(:tos_test_time) { DateTime.now }
  let(:auth_info) do
    {
      sandbox: {
        gateway: 's4ndb0x-g4t3w4y',
        oauth: 's4ndb0x-0kt4'
      },
      prod: {
        gateway: 'pr0d-g4t3w4y',
        oauth: 'pr0d-0kt4'
      }
    }
  end

  describe 'tests a valid consumer model' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'receives a description' do
      expect(subject[:description]).to eq(test_description)
    end

    it 'generates a tos_accepted_at value' do
      expect(subject[:tos_accepted_at]).to eq(tos_test_time)
    end

    it 'receives a tos_version' do
      expect(subject[:tos_version]).to eq(1)
    end

    it 'receives a sandbox_gateway_ref' do
      expect(subject[:sandbox_gateway_ref]).to eq(auth_info[:sandbox][:gateway])
    end

    it 'receives a sandbox_oauth_ref' do
      expect(subject[:sandbox_oauth_ref]).to eq(auth_info[:sandbox][:oauth])
    end

    it 'receives a prod_gateway_ref' do
      expect(subject[:prod_gateway_ref]).to eq(auth_info[:prod][:gateway])
    end

    it 'receives a prod_oauth_ref' do
      expect(subject[:prod_oauth_ref]).to eq(auth_info[:prod][:oauth])
    end
  end

  describe 'fails on an invalid input' do
    it 'fails without an email' do
      subject[:email] = nil
      expect(subject).not_to be_valid
    end
  end
end
