# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OktaService do
    let(:subject) { OktaService.new }

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

end
