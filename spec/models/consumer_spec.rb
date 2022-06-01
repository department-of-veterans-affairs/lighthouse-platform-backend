# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Consumer, type: :model do
  subject do
    Consumer.new(description: test_description,
                 organization: 'Test User Organization',
                 tos_accepted_at: tos_test_time,
                 tos_version: 1,
                 consumer_auth_refs_attributes: [
                   { key: ConsumerAuthRef::KEYS[:sandbox_gateway_ref], value: auth_info[:sandbox][:gateway] },
                   { key: ConsumerAuthRef::KEYS[:sandbox_acg_oauth_ref], value: auth_info[:sandbox][:acg_oauth] },
                   { key: ConsumerAuthRef::KEYS[:sandbox_ccg_oauth_ref], value: auth_info[:sandbox][:ccg_oauth] },
                   { key: ConsumerAuthRef::KEYS[:prod_gateway_ref], value: auth_info[:prod][:gateway] },
                   { key: ConsumerAuthRef::KEYS[:prod_acg_oauth_ref], value: auth_info[:prod][:acg_oauth] }
                 ],
                 user_id: parent[:id])
  end

  let(:parent) do
    create(:user,
           email: 'test_user@test_user_website.com',
           first_name: 'Test',
           last_name: 'User')
  end
  let(:test_description) { 'This is an in depth description.' }
  let(:tos_test_time) { Time.zone.now.change(usec: 0) }
  let(:auth_info) do
    {
      sandbox: {
        gateway: 's4ndb0x-g4t3w4y',
        acg_oauth: 's4ndb0x-acg-0kt4',
        ccg_oauth: 's4ndb0x-ccg-0kt4'
      },
      prod: {
        gateway: 'pr0d-g4t3w4y',
        acg_oauth: 'pr0d-0kt4'
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
      sandbox_gateway_ref = subject.consumer_auth_refs.detect do |auth_ref|
        auth_ref[:key] == ConsumerAuthRef::KEYS[:sandbox_gateway_ref]
      end.value
      expect(sandbox_gateway_ref).to eq(auth_info[:sandbox][:gateway])
    end

    it 'receives a acg sandbox_oauth_ref' do
      sandbox_acg_oauth_ref = subject.consumer_auth_refs.detect do |auth_ref|
        auth_ref[:key] == ConsumerAuthRef::KEYS[:sandbox_acg_oauth_ref]
      end.value
      expect(sandbox_acg_oauth_ref).to eq(auth_info[:sandbox][:acg_oauth])
    end

    it 'receives a ccg sandbox_oauth_ref' do
      sandbox_ccg_oauth_ref = subject.consumer_auth_refs.detect do |auth_ref|
        auth_ref[:key] == ConsumerAuthRef::KEYS[:sandbox_ccg_oauth_ref]
      end.value
      expect(sandbox_ccg_oauth_ref).to eq(auth_info[:sandbox][:ccg_oauth])
    end

    it 'receives a prod_gateway_ref' do
      prod_gateway_ref = subject.consumer_auth_refs.detect do |auth_ref|
        auth_ref[:key] == ConsumerAuthRef::KEYS[:prod_gateway_ref]
      end.value
      expect(prod_gateway_ref).to eq(auth_info[:prod][:gateway])
    end

    it 'receives an acg prod_oauth_ref' do
      prod_acg_oauth_ref = subject.consumer_auth_refs.detect do |auth_ref|
        auth_ref[:key] == ConsumerAuthRef::KEYS[:prod_acg_oauth_ref]
      end.value
      expect(prod_acg_oauth_ref).to eq(auth_info[:prod][:acg_oauth])
    end
  end

  describe 'fails on an invalid input' do
    it 'fails without an organization' do
      subject[:organization] = nil
      expect(subject).not_to be_valid
    end
  end
end
