# frozen_string_literal: true

module V0
  class Providers < V0::Base
    version 'v0'

    resource 'providers' do
      desc 'Return list of API providers'
      params do
        optional :status, type: String,
                          values: %w[active inactive],
                          allow_blank: true
      end
      get '/' do
        validate_token(Scope.provider_read)

        apis = Api
        apis = apis.kept if params[:status] == 'active'
        apis = apis.discarded if params[:status] == 'inactive'

        present apis.order(:name), with: V0::Entities::ApiEntity
      end

      desc 'Provide list of apis within categories as developer-portal expects', deprecated: true
      params do
        optional :environment, type: String,
                               values: %w[dev staging sandbox production],
                               allow_blank: true
      end
      get '/transformations/legacy' do
        categories = {}
        ApiCategory.kept.each do |category|
          categories[category.key] =
            V0::Entities::Legacy::ApiProviderCategoryEntity.represent(category)
        end

        categories
      end

      resource ':providerName' do
        desc 'Get list of release notes'
        params do
          requires :providerName, type: String, allow_blank: false, description: 'Name of provider'
        end
        get '/release-notes' do
          validate_token(Scope.provider_read)

          release_notes = Api.find_by!(name: params[:providerName]).api_metadatum.api_release_notes.kept

          present release_notes.kept.order(date: :desc), with: V0::Entities::ApiReleaseNoteEntity
        end

        desc 'Publish release note to an active API provider'
        params do
          requires :providerName, type: String, allow_blank: false, description: 'Name of provider'
          optional :date, type: Date, allow_blank: false, default: Time.zone.now.to_date.strftime('%Y-%m-%d')
          requires :content, type: String, allow_blank: false
        end
        post '/release-notes' do
          validate_token(Scope.provider_write)

          api_metadatum = Api.kept.find_by!(name: params[:providerName]).api_metadatum
          release_note = ApiReleaseNote.create(api_metadatum_id: api_metadatum.id,
                                               date: params[:date],
                                               content: CGI.unescape(params[:content]))

          present release_note, with: V0::Entities::ApiReleaseNoteEntity, base_url: request.base_url
        end
      end
    end
  end
end
