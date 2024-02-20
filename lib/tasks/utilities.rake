# frozen_string_literal: true

namespace :utilities do
  desc 'Returns list of consumers'
  task :consumers, [:apiId, :apiEnvironment] => [:environment] do |_, args|
    # no filters provided, return all consumers
    puts args[:apiId]
    puts args[:apiEnvironment]
    unless args[:apiId]
      users = User.kept.select { |user| user.consumer.present? }
      puts users
    else
      api_id_filter = args[:apiId]
      environment_filter = args[:apiEnvironment]
  
      api = Api.find(api_id_filter)
      environment = Environment.find_by(name: environment_filter)
      api_environment = ApiEnvironment.find_by(environment: environment, api: api)
  
      users = api_environment.consumer_api_assignment.map do |record|
        record.consumer.user.kept? ? record.consumer.user : nil
      end.compact
  
      puts users, with: Entities::UserEntity  
    end
  end
end
