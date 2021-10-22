# frozen_string_literal: true

desc 'loads the initial user, consumer and their API list'
task load_consumers: :environment do
  ConsumerImportService.new.import
end

desc 'creates users table in local dynamo db'
task initialize_dynamo: :environment do
  DynamoService.new.initialize_dynamo_db
end

desc 'seeds users table with mock data in local dynamo db'
task seed_dynamo: :environment do
  DynamoService.new.seed_dynamo_db
end
