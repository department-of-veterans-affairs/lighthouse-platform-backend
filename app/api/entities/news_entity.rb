# frozen_string_literal: true

module Entities
    class NewsEntity < Grape::Entity
      expose :id
      expose :title
      expose :url
      expose :category
      expose :created_at, as: :createdAt
      expose :updated_at, as: :updatedAt
    end
  end