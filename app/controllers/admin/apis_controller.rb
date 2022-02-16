# frozen_string_literal: true

require 'csv'
require 'rake'

class Admin::ApisController < ApplicationController
  def bulk_seed
    Rails.application.load_tasks
    Rake::Task['db:seed'].invoke

    redirect_to admin_dashboard_index_path
  end

  def destroy_all
    Api.discard_all

    redirect_to admin_dashboard_index_path
  end
end
