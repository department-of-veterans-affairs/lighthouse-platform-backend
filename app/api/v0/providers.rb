# frozen_string_literal: true

module V0
  class Providers < V0::Base
    version 'v0'

    resource 'providers' do
      desc 'Provide list of apis within categories as developer-portal expects', deprecated: true
      params do
        optional :environment, type: String,
                               values: %w[dev staging sandbox production],
                               allow_blank: true
      end
      get '/transformations/legacy' do
        categories = {}
        ApiCategory.kept.joins(:api_metadatum).order('api_categories.name, api_metadata.display_name').map do |category|
          categories[category.key] =
            V0::Entities::Legacy::ApiProviderCategoryEntity.represent(category)
        end

        categories
      end
    end
  end
end
