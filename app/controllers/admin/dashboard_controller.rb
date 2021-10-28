# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  def index
    @apis = Api.kept
    @users = User.kept
  end
end
