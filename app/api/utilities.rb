# frozen_string_literal: true

require 'rake'

class Utilities < Base
  resource 'utilities' do
    resource 'rake-tasks' do
      desc 'Run data migrations'
      params do
        requires :task, type: String, allow_blank: false, values: ['data:migrate']
      end
      post '/:task/requests' do
        Rails.application.load_tasks if Rake.application.tasks.blank?
        Rake::Task[params[:task]].execute

        { success: true }
      end
    end

    resource 'database' do
      desc 'Seed database with preset API data'
      post '/seed-requests' do
        Rails.application.load_tasks
        Rake::Task['db:seed'].invoke

        { success: true }
      end

      desc 'Migrate consumers from existing dynamo database'
      post '/consumer-migration-requests' do
        job = ConsumerMigrationJob.perform_later

        { jid: job.job_id }
      end

      desc 'Imports events from Dynamo DB'
      post '/event-migration-requests' do
        job = DynamoImportJob.perform_later

        { jid: job.job_id }
      end
    end

    resource 'consumers' do
      desc 'Returns list of consumers'
      get '/' do
        users = User.kept.select { |user| user.consumer.present? }

        present users, with: Entities::UserEntity
      end

      desc 'Delete all consumers'
      params do
        optional :destroy, type: Boolean,
                           allow_blank: false,
                           default: false,
                           values: [true, false],
                           description: 'False simply flags the records in the db, true destroys them forever'
      end
      delete '/' do
        params[:destroy] ? User.destroy_all : User.discard_all

        { success: true }
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

      desc 'Delete all APIs'
      params do
        optional :destroy, type: Boolean,
                           allow_blank: false,
                           default: false,
                           values: [true, false],
                           description: 'False simply flags the records in the db, true destroys them forever'
      end
      delete '/' do
        params[:destroy] ? Api.destroy_all : Api.discard_all

        { success: true }
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
        optional :filterLastDay, type: Boolean, allow_blank: false, values: [true, false], default: false
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
        optional :filterLastDay, type: Boolean, allow_blank: false, values: [true, false], default: false
      end
      get '/environments/:environment/unknown-applications' do
        drift_service_arg = params[:environment] == 'production' ? :production : nil
        Okta::DriftService.new(drift_service_arg).detect_drift(alert: false, filter: params[:filterLastDay])
      end
    end
  end
end
