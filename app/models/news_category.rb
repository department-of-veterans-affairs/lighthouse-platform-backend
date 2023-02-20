# frozen_string_literal: true

class NewsCategory < ApplicationRecord
  include Discard::Model

  validates :call_to_action, :description, :media, :title, presence: true
  has_many :news_item, dependent: :destroy
end
