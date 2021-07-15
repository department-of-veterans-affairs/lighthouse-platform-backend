# frozen_string_literal: true

Rails.application.routes.draw do
  # everything must scoped under platform-backend
  scope '/platform-backend' do
    get 'admin/dashboard', to: 'admin/dashboard#index'
  end
end
