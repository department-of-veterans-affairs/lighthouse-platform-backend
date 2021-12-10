# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiRef, type: :model do
  subject do
    ApiRef.new(name: 'swingline_staplers',
               api_id: api.id)
  end

  let :api do
    FactoryBot.create(:api,
                      name: 'Stapler Appeals')
  end

  describe 'tests a valid ApiRef model' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'requires a name to be valid' do
      expect(subject.name).to eq('swingline_staplers')
    end
  end

  describe 'tests an incorrect input' do
    it 'will be invalid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
    end
  end
end
