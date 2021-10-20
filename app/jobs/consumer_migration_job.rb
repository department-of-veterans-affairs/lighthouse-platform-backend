class ConsumerMigrationJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ConsumerImportService.new.import
  end
end
