# frozen_string_literal: true

module V0
  class Reports < V0::Base
    version 'v0'

    resource 'reports' do
      desc 'Provides consumer reports from gateway logs'
      get '/first-call/:id' do
        params do
          requires :id, type: String, allow_blank: false,
                        description: 'User ID from Lighthouse Consumer Management Service'
        end
        consumer = User.find(params[:id]).consumer
        ElasticsearchService.new.first_successful_call consumer
      end
    end
  end
end
