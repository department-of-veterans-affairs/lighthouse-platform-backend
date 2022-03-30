# frozen_string_literal: true

module V0
  class Environments < V0::Base
    version 'v0'

    resource 'environments' do
      desc 'Returns a list of available environments'
      get '/' do
        environments = Environment.all.kept
        present environments.order(:name), with: V0::Entities::EnvironmentEntity
      end

      desc 'Returns an environment by id'
      params do
        requires :id, type: Integer, allow_blank: false
      end
      get '/:id' do
        environment = Environment.find(params[:id])
        present environment, with: V0::Entities::EnvironmentEntity
      end
    end
  end
end
