# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @apis = Api.joins(:api_ref, :api_environments).kept
    @users = User.kept.select { |user| user.consumer.present? }
  end
end
