# frozen_string_literal: true

module Entities
  class NewsCategoryEntity < Grape::Entity
    expose :call_to_action, as: :callToAction
    expose :description
    expose :media
    expose :news_items, as: :items, using: Entities::NewsItemEntity
    expose :title
  end
end
