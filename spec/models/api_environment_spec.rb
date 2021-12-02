# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiEnvironment, type: :model do
  subject do
    ApiEnvironment.new(api_id: api.id,
                       environments_attributes: { name: 'TheMoon' },
                       metadata_url: 'http://outofthisworldsuits.com')
  end

  let :api do
    create(:api,
           name: 'Space Suit Vendors')
  end

  describe 'tests a valid ApiEnvironment model' do
    it 'is valid' do
      expect(subject).to be_valid
      expect(subject.environment).to be_valid
    end
  end

  describe 'tests an incorrect input' do
    it 'will be invalid without an api_id' do
      subject.api_id = nil
      expect(subject).not_to be_valid
    end
  end
end
