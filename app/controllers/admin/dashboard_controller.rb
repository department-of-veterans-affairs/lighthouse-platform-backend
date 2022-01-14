# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  before_action :handle_authenticate

  def index
    @apis = Api.kept
    @environments = Environment.kept
    @users = User.kept.select { |user| user.consumer.present? }
  end

  private

  def handle_authenticate
    return if Figaro.env.enable_github_auth.blank?

    authenticate_user!
  end
end
