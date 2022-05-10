# frozen_string_literal: true

namespace :kong do
  desc 'generates consumers within Kong Gateway.'
  task seed_consumers: :environment do
    Utility::SeedService.new.seed_kong_consumers
  end

  desc 'runs all seeds for Kong Gateway'
  task seed_gateway: :environment do
    Utility::SeedService.new.seed_kong
  end
end
