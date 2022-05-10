# frozen_string_literal: true

class SlackService
  def initialize
    @client = Slack::Web::Client.new
  end

  def send_message(channel, message)
    if use_string? message
      @client.chat_postMessage(channel: channel, text: message, as_user: true)
    else
      @client.chat_postMessage(channel: channel, attachments: message[:attachments],
                               as_user: true)
    end
  end

  def send_slack_signup_alert(options)
    send_message(Figaro.env.slack_signup_channel, success_message(slack_signup_message(options)))
  end

  private

  def slack_signup_message(options)
    [
      "#{options[:first_name]}, #{options[:last_name]}: #{slack_email_list(options)}",
      "Description: #{options[:description]}",
      'Requested access to:',
      options[:apis].map { |api| "* #{api.api_ref.name}" }.join("\n")
    ].join(" \n")
  end

  def include_va_email?(options)
    options[:internal_api_info][:va_email].present? if options[:internal_api_info]
  end

  def slack_email_list(options)
    "Contact Email: #{options[:email]}"\
      "#{include_va_email?(options) ? " | VA Email: #{options[:internal_api_info][:va_email]}" : ''}"
  end

  def success_message(message)
    {
      attachments: [
        {
          color: 'good',
          fallback: message,
          text: message,
          title: 'New User Application'
        }
      ]
    }
  end

  def use_string?(message)
    message.instance_of?(String)
  end
end
