# frozen_string_literal: true

class ConsumerMigrationJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    ConsumerImportService.new.import
  end
end
