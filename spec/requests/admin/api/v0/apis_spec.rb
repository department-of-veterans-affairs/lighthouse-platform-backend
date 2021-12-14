# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Api::V0::Apis', type: :request do
  describe 'Creating an API' do
    def valid_params
      {
        api: { name: 'claims' }
      }
    end

    def valid_bulk_params
      [{
        api: {
          name: 'claims',
          acl: 'claimville'
        }
      }]
    end

    def invalid_params
      {
        api: {
          not_a_name: 'claims'
        }
      }
    end

    it 'creates a new api record' do
      expect do
        post '/platform-backend/admin/api/v0/apis', params: valid_params
      end.to change(Api, :count).by(1)
    end

    it 're-uses existing record' do
      expect do
        post '/platform-backend/admin/api/v0/apis', params: valid_params
        Api.find(JSON.parse(response.body)['id']).discard
        post '/platform-backend/admin/api/v0/apis', params: valid_params
      end.to change(Api, :count).by(1)
    end

    it 'responds properly with a 422 when invalid' do
      expect do
        post '/platform-backend/admin/api/v0/apis', params: invalid_params
      end.to change(Api, :count).by(0)
      expect(response.code).to eq('422')
    end

    it 'creates a new api record for bulk update endpoint' do
      expect do
        post '/platform-backend/admin/api/v0/apis/bulk_upload', params: { apis: valid_bulk_params }
      end.to change(Api, :count).by(1)
    end

    it 'creates a new api record for bulk update endpoint via file upload' do
      expect do
        file = fixture_file_upload('spec/support/apis_list.csv', 'text/csv')
        post '/platform-backend/admin/api/v0/apis/bulk_upload', params: { file: file }
      end.to change(Api, :count).by(2)
    end
  end

  describe 'Deleting APIs' do
    it 'discards all apis' do
      FactoryBot.create(:api, name: 'Claims API')

      post '/platform-backend/admin/api/v0/apis/destroy_all'
      expect(response.status).to eq(302)
    end
  end
end
