# frozen_string_literal: true

require 'rake'

class Utilities < Base
  resource 'utilities' do
    resource 'consumers' do
      desc 'Returns list of consumers'
      get '/' do
        users = User.kept.select { |user| user.consumer.present? }

        present users, with: Entities::UserEntity
      end

      desc 'Returns last week signups report'
      get '/signups-report' do
        Slack::ReportService.new.query_events
      end
    end

    resource 'apis' do
      desc 'Return list of APIs'
      get '/' do
        apis = Api.left_joins(:api_ref).kept

        present apis, with: Entities::ApiEntity
      end
    end

    resource 'kong' do
      desc 'Return list Kong consumers'
      get '/consumers' do
        Kong::SandboxService.new.list_all_consumers
      end

      desc 'Return list Kong consumers not in LPB'
      params do
        requires :environment, type: String, allow_blank: false, values: %w[sandbox production], default: 'sandbox'
        optional :filterLastDay, type: Boolean, allow_blank: false, values: [true, false], default: true
      end
      get '/environments/:environment/unknown-consumers' do
        drift_service_arg = params[:environment] == 'production' ? :production : nil
        Kong::DriftService.new(drift_service_arg).detect_drift(alert: false, filter: params[:filterLastDay])
      end
    end

    resource 'okta' do
      desc 'Return list Okta applications not in LPB'
      params do
        requires :environment, type: String, allow_blank: false, values: %w[sandbox production], default: 'sandbox'
        optional :filterLastDay, type: Boolean, allow_blank: false, values: [true, false], default: true
      end
      get '/environments/:environment/unknown-applications' do
        drift_service_arg = params[:environment] == 'production' ? :production : nil
        Okta::DriftService.new(drift_service_arg).detect_drift(alert: false, filter: params[:filterLastDay])
      end
    end
  end
end
