# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConsumerApiAssignment, type: :model do
  subject do
    FactoryBot.build(:consumer_api_assignment,
                     consumer: consumer,
                     api_environment: api_environment)
  end

  let(:current_time) { DateTime.now }
  let(:user) { FactoryBot.create(:user) }
  let(:consumer) { FactoryBot.create(:consumer, user: user) }
  let(:api_environment) { FactoryBot.build(:api_environment) }

  describe 'creates a valid ConsumerApiAssignment' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'receives a consumer_id' do
      expect(subject.consumer_id).to eq(consumer.id)
    end

    it 'receives an api_environment' do
      expect(subject.api_environment_id).to eq(api_environment.id)
    end
  end

  describe 'fails on an invalid input' do
    it 'fails without a consumer_id' do
      subject.consumer_id = nil
      expect(subject).not_to be_valid
    end

    it 'fails without an api_environment' do
      subject.api_environment = nil
      expect(subject).not_to be_valid
    end
  end
end
