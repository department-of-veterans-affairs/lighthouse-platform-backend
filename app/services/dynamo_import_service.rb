# frozen_string_literal: true

class DynamoImportService
  def import_dynamo_events
    table_data = DynamoService.new.fetch_dynamo_db
    events = build_events(table_data['items'])
    Event.upsert_all(events)
  end

  private

  def build_events(events)
    events.map do |event|
      { event_type: Event::EVENT_TYPES[:sandbox_signup], content: event, created_at: event['createdAt'] }
    end
  end
end
