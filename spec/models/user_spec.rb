# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:test_email) { 'chuck.norris@texas_rangers_rule.com' }

  describe 'tests a valid user model' do
    subject do
      User.new(email: test_email,
               first_name: 'Chuck',
               last_name: 'Norris',
               organization: 'Texas Ranger')
    end

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'requires an email to be valid' do
      expect(subject.email).to eq(test_email)
    end

    it 'requires a first_name to be valid' do
      expect(subject.first_name).to eq('Chuck')
    end

    it 'requires a last_name to be valid' do
      expect(subject.last_name).to eq('Norris')
    end

    it 'requires an organization to be valid' do
      expect(subject.organization).to eq('Texas Ranger')
    end
  end

  describe 'tests an incorrect input' do
    subject do
      User.new(email: test_email,
               first_name: 'Chuck',
               last_name: 'Norris',
               organization: 'Texas Ranger')
    end

    it 'will not save without an email' do
      subject.email = nil
      expect(subject).not_to be_valid
    end

    it 'will not save without a first_name' do
      subject.first_name = nil
      expect(subject).not_to be_valid
    end

    it 'will not save without an last_name' do
      subject.last_name = nil
      expect(subject).not_to be_valid
    end

    it 'will not save without an organization' do
      subject.organization = nil
      expect(subject).not_to be_valid
    end
  end
end
