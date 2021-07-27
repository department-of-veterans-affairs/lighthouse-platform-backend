# frozen_string_literal: true

# Handles POST /github route to trigger email/slack notification
class GithubAlertsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    creator = GithubAlertCreator.new(alert_params)
    if creator.valid?
      creator.call
      render json: creator.to_json, status: :no_content
    else
      # raise to sentry after its integrated
      render json: creator.errors.to_json
    end
  end

  private

  def alert_params
    params.permit(
      alert: [:secret_type],
      repository: %i[full_name html_url],
      organization: [:login]
    )
  end
end
