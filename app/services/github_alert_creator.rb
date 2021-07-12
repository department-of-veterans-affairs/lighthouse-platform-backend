# frozen_string_literal: true

require 'net/http'
require 'uri'

# This class delivers creates and sends an email and slack notification
class GithubAlertCreator < ApplicationService
  attr_reader :body

  def initialize(body)
    @body = body
  end

  # rubocop:disable Metrics/MethodLength
  def call
    # Send Email
    GithubMailer.security_email(@body).deliver_now

    payload = {
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: 'A Secret has been found on Github',
            emoji: true
          }
        },
        {
          type: 'divider'
        },
        {
          type: 'section',
          fields: [
            {
              type: 'plain_text',
              text: 'Secret:',
              emoji: true
            },
            {
              type: 'plain_text',
              text: @body.dig(:alert, :secret_type),
              emoji: true
            }
          ]
        },
        {
          type: 'section',
          fields: [
            {
              type: 'plain_text',
              text: 'Repo:',
              emoji: true
            },
            {
              type: 'plain_text',
              text: @body.dig(:repository, :full_name),
              emoji: true
            }
          ]
        },
        {
          type: 'section',
          fields: [
            {
              type: 'plain_text',
              text: 'Url:',
              emoji: true
            },
            {
              type: 'plain_text',
              text: @body.dig(:repository, :html_url),
              emoji: true
            }
          ]
        },
        {
          type: 'section',
          fields: [
            {
              type: 'plain_text',
              text: 'Organization:',
              emoji: true
            },
            {
              type: 'plain_text',
              text: @body.dig(:organization, :login),
              emoji: true
            }
          ]
        },
        {
          type: 'actions',
          elements: [
            {
              type: 'button',
              text: {
                type: 'plain_text',
                text: 'Open in Browser',
                emoji: true
              },
              value: 'click_me_123',
              url: @body.dig(:repository, :html_url),
              action_id: 'button-action'
            }
          ]
        }
      ]
    }
    # Send Slack Message
    Net::HTTP.post(
      URI(ENV['SLACK_WEBHOOK_URL']),
      payload.to_json,
      'Content-Type' => 'application/json'
    )
  end
  # rubocop:enable Metrics/MethodLength
end
