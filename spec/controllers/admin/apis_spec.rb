# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::ApisController', type: :request do
  describe 'Creating an API' do
    def valid_bulk_params
      [{
        api: {
          name: 'claims',
          acl: 'claimville'
        }
      }]
    end

    it 'creates a new api record for bulk update endpoint' do
      expect do
        post '/platform-backend/admin/dashboard/apis/bulk_upload', params: { apis: valid_bulk_params }
      end.to change(Api, :count).by(1)
    end

    it 'creates a new api record for bulk update endpoint via file upload' do
      expect do
        file = fixture_file_upload('spec/support/apis_list.csv', 'text/csv')
        post '/platform-backend/admin/dashboard/apis/bulk_upload', params: { file: file }
      end.to change(Api, :count).by(2)
    end
  end

  describe 'Deleting APIs' do
    it 'discards all apis' do
      FactoryBot.create(:api, name: 'Claims API')

      post '/platform-backend/admin/dashboard/apis/destroy_all'
      expect(response.status).to eq(302)
    end
  end
end
