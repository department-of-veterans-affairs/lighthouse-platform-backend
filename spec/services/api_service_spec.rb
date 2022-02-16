# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiService do
  let(:api_environments) { create_list(:api_environment, 3) }
  let(:apis) { api_environments.map(&:api) }

  before do
    api_environments
    api = Api.find(apis.last.id)
    api.update!(acl: nil)
    api.update!(auth_server_access_key: 'TEST')
  end

  describe '.intialize' do
    let(:subject) { ApiService.new }
  end

  describe '#gather_apis' do
    it 'provides a list of apis' do
      result = subject.gather_apis("#{apis.first.api_ref.name},#{apis.last.api_ref.name}")
      expect(result.length).to eq(2)
      expect(result.first.name).to eq(apis.first.name)
    end

    it 'filters the correct apis' do
      result = subject.gather_apis("#{apis.first.api_ref.name},#{apis.second.api_ref.name}")
      expect(result.length).to eq(2)
      expect(result.map.collect(&:name)).not_to include(apis.last.name)
      expect(result.map.collect(&:name).sort).to eq([apis.first.name, apis.second.name].sort)
    end
  end

  describe '#fetch_auth_types' do
    it 'provides a list of respective key auth types' do
      key_auth, _oauth = subject.fetch_auth_types("#{apis.first.api_ref.name},#{apis.last.api_ref.name}")
      expect(key_auth.length).to eq(1)
      expect(key_auth[0]).to eq(Api.first.acl)
    end

    it 'provides a list of respective Oauth types' do
      _key_auth, oauth = subject.fetch_auth_types("#{apis.second.api_ref.name},#{apis.last.api_ref.name}")
      expect(oauth.length).to eq(1)
      expect(oauth.first).to eq(Api.last.auth_server_access_key)
    end
  end
end
