# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api, type: :model do
  subject do
    Api.new(name: 'Appeals Status API',
            auth_method: 'key_auth',
            environment: 'sandbox',
            open_api_url: '/services/appeals/docs/v0/api',
            base_path: '/services/appeals/v0/appeals',
            service_ref: 's3Rv1c3-r3f',
            api_ref: 'appeals')
  end

  describe 'tests a valid Api model' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'requires a name to be valid' do
      expect(subject.name).to eq('Appeals Status API')
    end

    it 'requires a auth_method to be valid' do
      expect(subject.auth_method).to eq('key_auth')
    end

    it 'requires a environment to be valid' do
      expect(subject.environment).to eq('sandbox')
    end

    it 'requires an open_api_url to be valid' do
      expect(subject.open_api_url).to eq('/services/appeals/docs/v0/api')
    end

    it 'requires an base_path to be valid' do
      expect(subject.base_path).to eq('/services/appeals/v0/appeals')
    end

    it 'requires an service_ref to be valid' do
      expect(subject.service_ref).to eq('s3Rv1c3-r3f')
    end

    it 'requires an api_ref to be valid' do
      expect(subject.api_ref).to eq('appeals')
    end
  end

  describe 'tests an incorrect input' do
    it 'will be invalid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it 'will be invalid without an auth_method' do
      subject.auth_method = nil
      expect(subject).not_to be_valid
    end

    it 'will be invalid without an environment' do
      subject.environment = nil
      expect(subject).not_to be_valid
    end

    it 'will be invalid without a base_path' do
      subject.base_path = nil
      expect(subject).not_to be_valid
    end

    it 'will be invalid without a service_ref' do
      subject.service_ref = nil
      expect(subject).not_to be_valid
    end

    it 'will be invalid without a api_ref' do
      subject.api_ref = nil
      expect(subject).not_to be_valid
    end
  end
end
