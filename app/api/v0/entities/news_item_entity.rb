# frozen_string_literal: true

module V0
  module Entities
    class NewsItemEntity < Grape::Entity
      expose :id
      expose :date
      expose :source
      expose :title
      expose :url
      expose :created_at, as: :createdAt
      expose :updated_at, as: :updatedAt
    end
  end
end
