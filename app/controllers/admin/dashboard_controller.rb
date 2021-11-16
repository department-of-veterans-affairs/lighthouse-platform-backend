# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @apis = Api.kept
    @users = User.select { |user| user.consumer.present?}
  end
end
