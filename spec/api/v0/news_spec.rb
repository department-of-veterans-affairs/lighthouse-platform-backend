# frozen_string_literal: true

require 'rails_helper'

describe V0::News, type: :request do
  describe 'returns list of news' do
    it 'returns all news' do
      get '/platform-backend/v0/news'
      expect(response.code).to eq('200')
    end
  end

  describe 'post news category' do
    it 'creates a valid news category' do
      expect do
        params = { callToAction: 'Read this!', description: 'Some news', media: false, title: 'News' }
        post '/platform-backend/v0/news/categories', params: params
        expect(response).to have_http_status(:created)
      end.to change(NewsCategory, :count).by 1
    end
  end
end
