# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiService do
  before do
    benefits_api
    benefits_ref
    claims_api
    claims_ref
    oauth_api
    oauth_ref
  end

  let(:benefits_api) { create(:api, name: 'Benefits', acl: 'benefits') }
  let(:benefits_ref) { create(:api_ref, name: 'benefits', api_id: benefits_api.id) }
  let(:claims_api) { create(:api, name: 'Claims', acl: 'claims') }
  let(:claims_ref) { create(:api_ref, name: 'claims', api_id: claims_api.id) }
  let(:oauth_api) { create(:api, name: 'Oauth', acl: '') }
  let(:oauth_ref) { create(:api_ref, name: 'oauth', api_id: oauth_api.id) }

  describe '.intialize' do
    let(:subject) { ApiService.new }
  end

  describe '#gather_apis' do
    it 'provides a list of apis' do
      result = subject.gather_apis('claims')
      expect(result.length).to eq(1)
      expect(result.first.name).to eq('Claims')
    end

    it 'filters the correct apis' do
      result = subject.gather_apis('claims,oauth')
      expect(result.length).to eq(2)
      expect(result.map.collect(&:name)).not_to include('Benefits')
      expect(result.map.collect(&:name).sort).to eq(%w[Claims Oauth])
    end
  end

  describe '#fetch_auth_types' do
    it 'provides a list of respective key auth types' do
      key_auth, _oauth = subject.fetch_auth_types('claims')
      expect(key_auth.length).to eq(1)
      expect(key_auth[0]).to eq('claims')
    end

    it 'provides a list of respective Oauth types' do
      _key_auth, oauth = subject.fetch_auth_types('oauth')
      expect(oauth.length).to eq(1)
      expect(oauth.first.name).to eq('Oauth')
    end
  end
end
