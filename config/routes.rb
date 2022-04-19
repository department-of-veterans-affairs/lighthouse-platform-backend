# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  root to: redirect('/platform-backend/admin/dashboard'), as: 'rootiest_root'

  scope '/platform-backend' do # everything must be scoped under platform-backend for DVP load balancer reqs
    root to: 'home#index'

    mount OkComputer::Engine, at: '/health_check'
    devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

    mount RailsAdmin::Engine => '/admin/database', as: 'rails_admin'

    mount Flipper::UI.app(Flipper) => '/admin/flipper', as: 'flipper'

    mount Base => '/'

    namespace :admin do
      root to: redirect('/platform-backend/admin/dashboard')
      mount GrapeSwaggerRails::Engine => '/dashboard'
      mount Sidekiq::Web => '/sidekiq'
    end

    match '*path', to: 'application#not_found', via: :all
  end
end
