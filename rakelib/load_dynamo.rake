# frozen_string_literal: true

desc 'loads the initial user, consumer and their API list'
task load_consumers: :environment do
  ConsumerImportService.new.import
end

namespace :dynamo do
  desc 'creates users table in local dynamo db'
  task migrate: :environment do
    Utility::SeedService.new.initialize_dynamo_db
  end

  desc 'seeds users table with mock data in local dynamo db'
  task seed_table: :environment do
    Utility::SeedService.new.seed_dynamo_db
  end

  desc 'initializes and seeds dynamo db'
  task seed: :environment do
    Utility::SeedService.new.seed_dynamo
  end
end
