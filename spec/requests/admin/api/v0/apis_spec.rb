# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Api::V0::Apis', type: :request do
  describe 'Creating an API' do
    # rubocop:disable Metrics/MethodLength
    def valid_params
      {
        api: {
          name: 'claims',
          auth_method: 'key_auth',
          environment: 'sandbox',
          open_api_url: 'https://sandbox-api.va.gov/services/claims/docs/v0/api',
          base_path: '/services/claims/v0',
          service_ref: 'somerandom-guid',
          api_ref: 'claims'
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def invalid_params
      {
        api: {
          name: 'claims'
        }
      }
    end

    it 'creates a new api record' do
      expect do
        post '/platform-backend/admin/api/v0/apis', params: valid_params
      end.to change(Api, :count).by(1)
    end

    it 'responds properly with a 422 when invalid' do
      expect do
        post '/platform-backend/admin/api/v0/apis', params: invalid_params
      end.to change(Api, :count).by(0)
      expect(response.code).to eq('422')
    end
  end
end
