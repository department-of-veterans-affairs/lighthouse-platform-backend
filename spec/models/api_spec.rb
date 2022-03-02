# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api, type: :model do
  subject do
    Api.new(name: 'Appeals Status API',
            acl: 'lca')
  end

  describe 'tests a valid Api model' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'requires a name to be valid' do
      expect(subject.name).to eq('Appeals Status API')
    end

    it 'requires an acl to be valid' do
      expect(subject.acl).to eq('lca')
    end

    it 'undiscards a previously discarded record' do
      subject.discard
      expect(subject.discarded_at).not_to be_nil
      subject.undiscard
      expect(subject.discarded_at).to be_nil
    end
  end

  describe 'tests an incorrect input' do
    it 'will be invalid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
    end
  end
end
