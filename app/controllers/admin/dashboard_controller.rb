# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  def index
    @apis = Api.all
    @users = User.all
  end
end
