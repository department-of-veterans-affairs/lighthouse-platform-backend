# frozen_string_literal: true

class News < ApplicationRecord
  include Discard::Model

  validates :title, :url, presence: true
end
