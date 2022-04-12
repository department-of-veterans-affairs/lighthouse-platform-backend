# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Okta::ProductionService do
  subject { Okta::ProductionService.new }

  describe 'receives sandbox' do
    it 'as the environment values' do
      expect(subject.send(:idme_group)).to eq(Figaro.env.prod_idme_group_id)
      expect(subject.send(:okta_api_endpoint)).to eq(Figaro.env.prod_okta_api_endpoint)
      expect(subject.send(:okta_token)).to eq(Figaro.env.prod_okta_token)
      expect(subject.send(:va_redirect)).to eq(Figaro.env.prod_okta_redirect_url)
    end
  end
end
