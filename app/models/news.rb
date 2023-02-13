# frozen_string_literal: true

class News < ApplicationRecord
  include Discard::Model

  CATEGORIES = {
    articles: 'articles',
    digital_media: 'digital_media',
    news_releases: 'news_releases'
  }.freeze

  validates :title, :url, presence: true
  validates :category, presence: true, acceptance: { accept: CATEGORIES.values }
end
