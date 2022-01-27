# frozen_string_literal: true

class Admin::ConsumersController < ApplicationController
  def load_initial
    job = ConsumerMigrationJob.perform_later

    params[:authenticity_token].present? ? redirect_to(admin_dashboard_index_path) : render(json: { jid: job.job_id })
  end

  def destroy_all
    User.discard_all

    redirect_to admin_dashboard_index_path
  end
end
