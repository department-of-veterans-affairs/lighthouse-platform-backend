# frozen_string_literal: true

class Admin::Api::V0::ConsumersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def load_initial
    job = ConsumerMigrationJob.perform_later
    render json: { jid: job.job_id }
  end
end
