# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiService do
  before do
    api_environments
  end
  
  let(:api_environments) { create_list(:api_environment, 3) }
  let(:api_one) { api_environments.first.api.name }
  let(:api_two) { api_environments.second.api.name }
  let(:api_three) { api_environments.last.api.name }
  let(:api_ref_one) { api_environments.first.api.api_ref.name }
  let(:api_ref_two) { api_environments.second.api.api_ref.name }
  let(:api_ref_three) { api_environments.last.api.api_ref.name }

  describe '.intialize' do
    let(:subject) { ApiService.new }
  end

  describe '#gather_apis' do
    it 'provides a list of apis' do
      result = subject.gather_apis(api_ref_one)
      expect(result.length).to eq(1)
      expect(result.first.name).to eq(api_one)
    end

    it 'filters the correct apis' do
      result = subject.gather_apis("#{api_ref_one},#{api_ref_two}")
      expect(result.length).to eq(2)
      expect(result.map.collect(&:name)).not_to include(api_three)
      expect(result.map.collect(&:name).sort).to eq([api_one, api_two].sort)
    end
  end

  describe '#fetch_auth_types' do
    it 'provides a list of respective key auth types' do
      api_ref = Api.first.api_ref.name
      key_auth, _oauth = subject.fetch_auth_types(api_ref)
      expect(key_auth.length).to eq(1)
      expect(key_auth[0]).to eq(Api.first.acl)
    end

    it 'provides a list of respective Oauth types' do
      api_ref = Api.second.api_ref.name
      _key_auth, oauth = subject.fetch_auth_types(api_ref)
      expect(oauth.length).to eq(1)
      expect(oauth.first).to eq(Api.second.auth_server_access_key)
    end
  end
end
