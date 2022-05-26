# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Environment, type: :model do
  subject do
    described_class.new(name: 'OuterSpace')
  end

  describe 'tests a valid Environment model' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'requires a name to be valid' do
      expect(subject.name).to eq('OuterSpace')
    end
  end

  describe 'tests an invalid Environment model' do
    it 'is invalid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
    end
  end
end
