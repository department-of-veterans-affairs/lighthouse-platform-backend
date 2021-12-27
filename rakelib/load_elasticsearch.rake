# frozen_string_literal: true

namespace :elasticsearch do
  desc 'generates data within Elasticsearch.'
  task seed: :environment do
    ElasticsearchService.new.seed_elasticsearch
  end
end
