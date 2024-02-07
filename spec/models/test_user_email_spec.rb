# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestUserEmail, type: :model do
  describe 'tests a valid TestUserEmail model' do
    subject do
      TestUserEmail.new(email: 'testymctesterface@theinternet.com')
    end

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'requires a email to be valid' do
      expect(subject.email).to eq('testymctesterface@theinternet.com')
    end

    it 'requires api fields to be false by default' do
      expect(subject.claims).to be(false)
      expect(subject.communityCare).to be(false)
      expect(subject.health).to be(false)
      expect(subject.verification).to be(false)
    end
  end

  describe 'tests the deeplinks' do
    it 'gathers deeplinks' do
      subject.get_deeplinks
    end
  end
end
