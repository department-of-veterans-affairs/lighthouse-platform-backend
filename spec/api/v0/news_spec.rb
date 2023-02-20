# frozen_string_literal: true

require 'rails_helper'

describe V0::News, type: :request do
  let(:news) { create_list(:news_category, 3) }

  before do
    news
  end

  describe 'returns list of news' do
    it 'returns all news' do
      get '/platform-backend/v0/news'
      expect(response.code).to eq('200')
    end
  end
end
