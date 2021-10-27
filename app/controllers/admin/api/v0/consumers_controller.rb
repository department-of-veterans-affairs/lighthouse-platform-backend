# frozen_string_literal: true

class Admin::Api::V0::ConsumersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def load_initial
    job = ConsumerMigrationJob.perform_later

    if params[:authenticity_token].present?
      redirect_to admin_dashboard_path
    else
      render json: { jid: job.job_id }
    end
  end

  def destroy_all
    User.destroy_all

    redirect_to admin_dashboard_path
  end
end
