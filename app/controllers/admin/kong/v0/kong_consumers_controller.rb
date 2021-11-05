# frozen_string_literal: true

class Admin::Kong::V0::KongConsumersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @consumers = KongService.new.list_all_consumers
    render json: @consumers
  end

  def show
    @consumer = KongService.new.get_consumer params[:id]
    render json: @consumer
  end
end
