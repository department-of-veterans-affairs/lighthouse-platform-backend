# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/platform-backend/admin/dashboard'), as: 'rootiest_root'

  scope '/platform-backend' do # everything must be scoped under platform-backend for DVP load balancer reqs
    root to: 'home#index'

    get '/sitemap.xml', to: 'home#sitemap'

    mount OkComputer::Engine, at: '/health_check'
    mount OkComputer::Engine, at: '/healthcheck', as: 'healthcheckiest_healthcheck'
    devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

    mount RailsAdmin::Engine => '/admin/database', as: 'rails_admin'

    flipper_constraint = lambda do |request|
      if ActiveRecord::Type::Boolean.new.deserialize(Figaro.env.enable_github_auth)
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

    namespace :v0 do
      mount OkComputer::Engine, at: '/healthcheck'
    end

    namespace :admin do
      root to: redirect('/platform-backend/admin/dashboard')
      mount GrapeSwaggerRails::Engine => '/dashboard'
    end

    match '*path', to: 'application#not_found', via: :all
  end
end
