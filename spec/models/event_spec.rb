# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:event) do
    described_class.create({
                             event_type: Faker::Lorem.unique.word,
                             content: { apis: 'test' }
                           })
  end

  describe 'an event' do
    it 'is valid' do
      expect(event).to be_valid
      expect(described_class.all.count).to eq(1)
    end

    it 'is labeled with an event type' do
      expect(event.event_type).to eq(described_class.first.event_type)
    end

    it 'has an event included' do
      expect(event.content).to eq(described_class.first.content)
    end
  end
end
