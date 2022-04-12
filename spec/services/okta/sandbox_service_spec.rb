# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Okta::SandboxService do
  subject { Okta::SandboxService.new }

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
end
