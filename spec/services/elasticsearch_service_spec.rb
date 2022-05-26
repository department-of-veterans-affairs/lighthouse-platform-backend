# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ElasticsearchService do
  describe '.intialize' do
    subject { described_class.new }

    it 'uses regular Net::HTTP to make a connection' do
      expect(subject.client.name).to eq('Net::HTTP')
    end
  end

  describe 'locates the first successful call in es' do
    let(:user) { create(:user) }
    let(:consumer) { create(:consumer, :with_sandbox_ids, user: user) }

    it 'retrieves a successful first call by a consumer' do
      expect(subject.first_successful_call(consumer)).to eq({ first_sandbox_interaction_at: 'July 03, 2015' })
    end
  end
end
