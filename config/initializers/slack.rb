# frozen_string_literal: true

Slack.configure do |config|
  config.token = Figaro.env.slack_api_token
end
