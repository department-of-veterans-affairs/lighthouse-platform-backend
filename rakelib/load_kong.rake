# frozen_string_literal: true

namespace :kong do
  desc "generates consumers within 'Sandbox' Kong Gateway."
  task seed_consumers: :environment do
    Utility::SeedService.new.seed_kong_consumers
  end

  desc "creates consumers and plugins within the 'Sandbox' Kong Gateway"
  task seed: :environment do
    Utility::SeedService.new.seed_kong
  end
end
