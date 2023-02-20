# frozen_string_literal: true

module Entities
  class NewsEntity < Grape::Entity
    expose :call_to_action, as: :callToAction
    expose :description
    expose :items, using: Entities::NewsItemEntity
    expose :media
    expose :title
  end
end
