# frozen_string_literal: true

require 'rails_helper'

describe Utilities, type: :request do
  describe 'APIs' do
    before do
      create(:api, name: 'Claims API')
    end

    it 'gets all apis' do
      get '/platform-backend/utilities/apis'
      expect(response.status).to eq(200)
    end

    it 'provides a list of api categories' do
      get '/platform-backend/utilities/apis/categories'
      expect(response.status).to eq(200)
    end
  end

  describe 'consumers' do
    before do
      user = create(:user)
      create(:consumer, user_id: user.id)
    end

    it 'gets all users/consumers' do
      get '/platform-backend/utilities/consumers'
      expect(response.status).to eq(200)
    end

    it 'gets weekly signups for consumers' do
      get '/platform-backend/utilities/consumers/signups-report'
      expect(response.status).to eq(200)
    end

    it 'gets unknown consumers in kong' do
      get '/platform-backend/utilities/kong/environments/sandbox/unknown-consumers'
      expect(response.status).to eq(200)
    end

    it 'gets unknown applications in okta' do
      VCR.use_cassette('okta/list_applications_200', match_requests_on: [:method]) do
        get '/platform-backend/utilities/okta/environments/sandbox/unknown-applications'
        expect(response.status).to eq(200)
      end
    end
  end
end
