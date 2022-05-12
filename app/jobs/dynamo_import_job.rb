# frozen_string_literal: true

class DynamoImportJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    DynamoImportService.new.import_dynamo_events
  end
end
