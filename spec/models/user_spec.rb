# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    user = {
      first_name: 'John',
      last_name: 'Smith',
      email: 'jsmith@email.com'
    }
    @user1 = described_class.create user
  end

  let(:test_email) { 'chuck.norris@texas_rangers_rule.com' }

  describe '.user' do
    it { expect(@user1).to(be_valid) }
  end

  auth_hash = OmniAuth::AuthHash.new(
    {
      provider: 'github',
      uid: '1234',
      info: {
        email: 'user@example.com',
        name: 'Gimli son of Gloin'
      }
    }
  )

  updated_auth_hash = OmniAuth::AuthHash.new(
    {
      provider: 'github',
      uid: '1234',
      info: {
        email: 'different.email@example.com',
        name: 'Gimly spelled wrong'
      }
    }
  )

  describe User, '#from_omniauth' do
    it 'creates an admin user if is_admin=true' do
      expect(described_class.count).to eq 1
      user = described_class.from_omniauth(auth_hash, true)
      expect(described_class.count).to eq 2

      expect(user.uid).to eq '1234'
      expect(user.email).to eq 'user@example.com'
      expect(user.first_name).to eq 'Gimli'
      expect(user.last_name).to eq 'Gloin'
      expect(user.role).to eq 'admin'
    end

    it 'retrieves an existing user' do
      user = described_class.new(
        provider: 'github',
        first_name: 'user',
        last_name: 'one',
        uid: '1234',
        email: 'user@example.com'
      )
      user.save
      omniauth_user = described_class.from_omniauth(auth_hash, false)

      expect(user).to eq(omniauth_user)
    end

    it 'creates a new user' do
      expect(described_class.count).to eq 1
      user = described_class.from_omniauth(auth_hash, false)
      expect(described_class.count).to eq 2

      expect(user.uid).to eq '1234'
      expect(user.email).to eq 'user@example.com'
      expect(user.first_name).to eq 'Gimli'
      expect(user.last_name).to eq 'Gloin'
      expect(user.role).to eq 'user'
    end

    it 'updates existing users' do
      expect(described_class.count).to eq 1
      described_class.from_omniauth(auth_hash, false)
      expect(described_class.count).to eq 2

      user = described_class.from_omniauth(updated_auth_hash, false)
      expect(user.email).to eq 'different.email@example.com'
      expect(user.first_name).to eq 'Gimly'
      expect(user.last_name).to eq 'wrong'

      user = described_class.from_omniauth(auth_hash, false)
      expect(user.email).to eq 'user@example.com'
      expect(user.first_name).to eq 'Gimli'
      expect(user.last_name).to eq 'Gloin'
    end
  end

  describe 'tests a valid user model' do
    subject do
      described_class.new(email: test_email,
                          first_name: 'Chuck',
                          last_name: 'Norris')
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
  end

  describe 'tests an incorrect input' do
    subject do
      described_class.new(email: test_email,
                          first_name: 'Chuck',
                          last_name: 'Norris')
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
  end
end
