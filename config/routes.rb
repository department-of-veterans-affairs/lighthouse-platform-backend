# frozen_string_literal: true

Rails.application.routes.draw do
  Healthcheck.routes(self)
  # everything must scoped under platform-backend
  scope '/platform-backend' do
    get 'admin/dashboard', to: 'admin/dashboard#index'
    post '/github', to: 'github#alert'
    resources :consumers
  end
end
