# frozen_string_literal: true

module V0
  module Entities
    class NewsCategoryEntity < Grape::Entity
      expose :callToAction
      expose :description
      expose :items
      expose :media
      expose :title
    end
  end
end
