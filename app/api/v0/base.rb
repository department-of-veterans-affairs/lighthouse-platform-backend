# frozen_string_literal: true

module V0
  class Base < Grape::API
    format :json
    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error!({
               errors: [
                 V0::Entities::ErrorEntity.represent({ title: 'Bad Request', detail: e.message })
               ]
             }, 400)
    end
    rescue_from :all do |e|
      error!({
               errors: [
                 V0::Entities::ErrorEntity.represent({ title: 'Internal Server Error', detail: e.message })
               ]
             }, 500)
    end

    mount V0::Consumers
  end
end
