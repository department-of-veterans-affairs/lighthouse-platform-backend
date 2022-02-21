# frozen_string_literal: true

require 'rails_helper'

describe V0::Providers, type: :request do
  describe 'accepts signups from dev portal' do
    let(:api_environments) { create_list(:api_environment, 3) }

    before do
      api_environments
      api = Api.last
      api.update!(auth_server_access_key: 'AUTHZ_SERVER_DEFAULT')
      api.update!(acl: nil)
    end

    it 'returns all apis in a form the developer-portal knows how to deal with' do
      get '/platform-backend/v0/providers/transformations/legacy'
      expect(response.code).to eq('200')

      expect(JSON.parse(response.body).count).to eq(3)
    end
  end
end
