# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KongService do
  describe '.intialize' do
    let(:subject) { KongService.new }

    describe 'hitting remote Kong' do
      it 'uses a socks client to make a connection' do
        socks_host = ENV['SOCKS_HOST'] || 'localhost'
        expect(subject.client.socks_server).to eq(socks_host)
      end
    end
  end

  describe '#list_consumers' do
    it 'retrieves up to the first 100 consumers' do
      VCR.use_cassette('kong/kong_consumers_200', match_requests_on: [:method]) do
        result = subject.list_consumers
        expect(result['data'].length).to eq(3)
        expect(result['data'].last['username']).to eq('RedbullPastrana')
      end
    end
  end
end
