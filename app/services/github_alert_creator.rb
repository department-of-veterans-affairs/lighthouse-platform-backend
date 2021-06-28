# frozen_string_literal: true

require 'net/http'
require 'uri'

# This class delivers creates and sends an email and slack notification
# rubocop:disable Metrics/ClassLength
class GithubAlertCreator < ApplicationService
  attr_reader :body

  def initialize(body)
    @body = body
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
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
              text: (@body[:alert][:secret_type]).to_s,
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
              text: (@body[:repository][:full_name]).to_s,
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
              text: (@body[:repository][:html_url]).to_s,
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
              text: (@body[:organization][:login]).to_s,
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
              url: (@body[:repository][:html_url]).to_s,
              action_id: 'button-action'
            }
          ]
        }
      ]
    }
    # Send Slack Message
    Net::HTTP.post(
      URI(ENV['GITHUB_WEBHOOK_URL']),
      payload.to_json,
      'Content-Type' => 'application/json'
    )
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
# rubocop:enable Metrics/ClassLength

