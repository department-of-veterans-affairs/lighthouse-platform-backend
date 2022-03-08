# frozen_string_literal: true

module V0
  class Reports < V0::Base
    version 'v0'

    resource 'reports' do
      desc 'Peruses Elasticsearch for a successful consumer first-call (via oauth and/or key-auth)'
      get '/first-call/:id' do
        params do
          requires :id, type: String, allow_blank: false,
                        description: 'User ID from Lighthouse Consumer Management Service'
        end
        consumer = User.find(params[:id]).consumer
        first_call = ElasticsearchService.new.first_successful_call consumer
        present first_call, with: V0::Entities::ReportEntity
      end
    end
  end
end
