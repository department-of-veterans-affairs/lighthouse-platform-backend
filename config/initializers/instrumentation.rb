# frozen_string_literal: true

ActiveSupport::Notifications.subscribe('grape_key') do |_name, _starts, _ends, _notification_id, payload|
  Rails.logger.info payload
end
