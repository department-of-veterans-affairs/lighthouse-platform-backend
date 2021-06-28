# frozen_string_literal: true

# Handles POST /github route to trigger email/slack notification
class GithubController < ApplicationController
  skip_before_action :verify_authenticity_token

  def alert
    # cutting out unnecessary keys
    req_body = {
      alert: params['alert'],
      repository: params['repository'],
      organization: params['organization']
    }

    GithubAlertCreator.call(req_body)
  end
end
