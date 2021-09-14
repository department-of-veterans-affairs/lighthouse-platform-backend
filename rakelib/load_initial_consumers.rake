# frozen_string_literal: true

desc 'loads the initial user, consumer and their API list'
task load_consumers: :environment do
  service = ConsumerImportService.new
  service.import
end
