# frozen_string_literal: true

class NewsCategory < ApplicationRecord
  include Discard::Model

  validates :title, presence: true, uniqueness: true
  validates :call_to_action, :description, :media, presence: true
  has_many :news_items, dependent: :destroy
end
