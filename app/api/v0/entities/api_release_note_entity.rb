# frozen_string_literal: true

module V0
  module Entities
    class ApiReleaseNoteEntity < Grape::Entity
      format_with(:date_only) do |date|
        date.strftime('%Y-%m-%d')
      end

      expose :date, format_with: :date_only
      expose :content, documentation: { type: String }
      expose :created_at, as: :createdAt

      expose '@links', if: :base_url, using: V0::Entities::LinkEntity do |instance, options|
        api_name = instance.api_metadatum.api.name

        [
          { rel: 'collection',
            type: 'GET',
            url: "#{options[:base_url]}/platform-backend/v0/providers/#{api_name}/release-notes" }
        ]
      end
    end
  end
end
