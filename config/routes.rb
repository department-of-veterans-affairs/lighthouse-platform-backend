# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/platform-backend/admin/dashboard'), as: 'rootiest_root'

  scope '/platform-backend' do # everything must be scoped under platform-backend for DVP load balancer reqs
    root to: 'home#index'

    mount OkComputer::Engine, at: '/health_check'
    devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

    mount RailsAdmin::Engine => '/admin/database', as: 'rails_admin'

    flipper_constraint = lambda do |request|
      if Figaro.env.enable_github_auth.present?
        begin
          request.env['warden'].authenticate!(scope: :user)
          true
        rescue
          false
        end
      else
        true
      end
    end
    constraints flipper_constraint do
      mount Flipper::UI.app(Flipper) => '/admin/flipper', as: 'flipper'
    end

    mount Base => '/'

    namespace :admin do
      root to: redirect('/platform-backend/admin/dashboard')
      mount GrapeSwaggerRails::Engine => '/dashboard'
    end

    match '*path', to: 'application#not_found', via: :all
  end
end
