# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConsumerApiAssignment, type: :model do
  subject do
    ConsumerApiAssignment.new(consumer_id: consumer.id,
                              api_id: api.id,
                              first_successful_call_at: current_time)
  end

  let(:current_time) { DateTime.now }
  let(:user) { FactoryBot.create(:user) }
  let(:consumer) { FactoryBot.create(:consumer, user: user) }
  let :api do
    FactoryBot.create(:api,
                      name: 'Appeals Status API',
                      acl: 'appeals_status_api')
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
