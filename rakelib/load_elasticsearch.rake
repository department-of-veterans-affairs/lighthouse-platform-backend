# frozen_string_literal: true

namespace :elasticsearch do
  desc 'generates data within Elasticsearch.'
  task seed: :environment do
    Utility::SeedService.new.seed_elasticsearch
  end
end
