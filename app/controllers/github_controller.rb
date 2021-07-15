# frozen_string_literal: true

# Handles POST /github route to trigger email/slack notification
class GithubController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :alert_params

  def alert
    # cutting out unnecessary keys
    req_body = {
      alert: params['alert'],
      repository: params['repository'],
      organization: params['organization']
    }

    GithubAlertCreator.call(req_body)
  end

  private

  def alert_params
    params.require(%i[alert repository organization])
  end
end
