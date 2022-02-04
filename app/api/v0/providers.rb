# frozen_string_literal: true

module V0
  class Providers < V0::Base
    version 'v0'

    resource 'providers' do
      desc 'Provide list of api providers'
      params do
        optional :environment, type: String,
                               values: %w[dev staging sandbox production],
                               allow_blank: true
      end
      get '/' do
        api_providers = Api.kept.displayable

        present api_providers, with: V0::Entities::ApiProviderEntity, environment: params[:environment]
      end
    end
  end
end
