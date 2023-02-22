# frozen_string_literal: true

module V0
  module Entities
    class NewsCategoryEntity < Grape::Entity
      expose :id
      expose :call_to_action, as: :callToAction
      expose :description
      expose :news_items, as: :items, using: V0::Entities::NewsItemEntity
      expose :media
      expose :title
    end
  end
end
