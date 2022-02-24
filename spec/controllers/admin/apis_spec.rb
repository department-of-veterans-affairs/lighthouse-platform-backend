# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::ApisController', type: :request do
  describe 'Creating an API' do
    it 'creates new api records through database seed file' do
      expect do
        post '/platform-backend/admin/dashboard/apis/bulk_seed'
      end.to change(Api, :count).by(14)
    end
  end

  describe 'Deleting APIs' do
    it 'discards all apis' do
      create(:api, name: 'Claims API')

      post '/platform-backend/admin/dashboard/apis/destroy_all'
      expect(response.status).to eq(302)
    end
  end
end
