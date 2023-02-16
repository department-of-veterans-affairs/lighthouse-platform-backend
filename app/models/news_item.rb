# frozen_string_literal: true

class NewsItem < ApplicationRecord
  include Discard::Model

  belongs_to :news_category
  validates :date, :title, :url, presence: true
end
