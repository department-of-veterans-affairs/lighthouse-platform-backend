# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConsumerApiAssignment, type: :model do
  subject do
    ConsumerApiAssignment.new(consumer_id: consumer.id,
                              api_id: api.id,
                              first_successful_call_at: current_time)
  end

  let(:current_time) { DateTime.now }
  let(:user) { create(:user) }
  let(:consumer) { create(:consumer, user: user) }
  let :api do
    create(:api,
           name: 'Appeals Status API',
           auth_method: 'key_auth',
           environment: 'sandbox',
           open_api_url: '/services/appeals/docs/v0/api',
           base_path: '/services/appeals/v0/appeals',
           service_ref: 's3Rv1c3-r3f',
           api_ref: 'appeals')
  end

  describe 'creates a valid ConsumerApiAssignment' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'receives a consumer_id' do
      expect(subject.consumer_id).to eq(consumer.id)
    end

    it 'receives an api_id' do
      expect(subject.api_id).to eq(api.id)
    end
  end

  describe 'fails on an invalid input' do
    it 'fails without a consumer_id' do
      subject.consumer_id = nil
      expect(subject).not_to be_valid
    end

    it 'fails without an api_id' do
      subject.api_id = nil
      expect(subject).not_to be_valid
    end
  end
end
