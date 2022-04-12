# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Okta::SandboxService do
  subject { Okta::SandboxService.new }

  let(:request) { Struct.new(:last_name, :consumer) }
  let(:nested) { Struct.new(:organization) }

  let :user do
    request.new(
      'BonJovi',
      nested.new('Testing')
    )
  end

  describe '#list applications' do
    it 'displays all applications' do
      VCR.use_cassette('okta/list_applications_200', match_requests_on: [:method]) do
        result = subject.list_applications
        expect(result.length).to eq(1)
        expect(result[0][:label]).to eq('OktaApplication')
        expect(result[0][:_links]).to have_key(:deactivate)
      end
    end
  end

  describe 'receives sandbox' do
    it 'as the environment values' do
      expect(subject.send(:idme_group)).to eq(Figaro.env.idme_group_id)
      expect(subject.send(:okta_api_endpoint)).to eq(Figaro.env.okta_api_endpoint)
      expect(subject.send(:okta_token)).to eq(Figaro.env.okta_token)
      expect(subject.send(:va_redirect)).to eq(Figaro.env.okta_redirect_url)
    end
  end

  describe 'uses the base service' do
    it 'builds needed values' do
      expect(subject.send(:consumer_name, user)).to eq('LPB-TestingBonJovi')
      expect(subject.send(:build_new_application_payload, user, application_type: 'web',
                                                                redirect_uri: 'example.com')).to include(:settings)
    end
  end
end
