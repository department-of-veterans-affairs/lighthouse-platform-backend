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
    let(:news_category) { create(:news_category, title: 'articles') }
    let(:news_item) { create(:news_item, news_category_id: news_category.id) }

    before do
      news_category
      news_item
    end

    it 'creates a news item' do
      expect do
        params = { category: 'articles', date: '01/01/2020', source: 'VA', title: 'Benefits', url: 'https://www.va.gov' }
        post "/platform-backend/v0/news/categories/#{news_category.title}/items", params: params
        expect(response).to have_http_status(:created)
      end.to change(NewsItem, :count).by 1
    end

    it 'updates a news item' do
      params = { category: 'articles', date: '01/01/2020', source: 'VA', title: 'Benefits', url: 'https://www.va.gov/benefits' }
      put "/platform-backend/v0/news/categories/articles/items/#{news_item.title}",
          params: params
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('url')
      expect(JSON.parse(response.body)['url']).to eq('https://www.va.gov/benefits')
    end
  end

  describe 'invalid news' do
    let(:invalid_news_category) { create(:news_category) }
    let(:invalid_news_item) { create(:news_item, news_category_id: 10) }

    before do
      invalid_news_category
      invalid_news_item
    end

    it 'returns an error if news category does not exist when adding a news item' do
      expect do
        params = { category: 'articles', date: '01/01/2020', source: 'VA', title: 'Benefits', url: 'https://www.va.gov' }
        post '/platform-backend/v0/news/categories/random-category/items', params: params
        expect(response.code).to eq('500')
        expect(response.body).to include('News category does not exist')
      end
    end

    it 'returns an error if news item does not exist' do
      params = { category: 'articles', date: '01/01/2020', source: 'VA', title: 'Benefits', url: 'https://www.va.gov/benefits' }
      put "/platform-backend/v0/news/categories/#{invalid_news_category.title}/items/#{invalid_news_item.title}",
          params: params
      expect(response.code).to eq('500')
      expect(response.body).to include('News item does not exist')
    end
  end
end
