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

  describe 'post news item' do
    let(:news_category) { create(:news_category) }

    before do
      news_category
    end

    it 'creates a valid news item for a given news category id' do
      expect do
        params = { categoryId: news_category.id, date: '01/01/2020', source: 'VA', title: 'Benefits', url: 'https://www.va.gov' }
        post "/platform-backend/v0/news/categories/#{news_category.id}/items", params: params
        expect(response).to have_http_status(:created)
      end.to change(NewsItem, :count).by 1
    end
  end
end
