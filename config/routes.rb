# frozen_string_literal: true

Rails.application.routes.draw do
  Healthcheck.routes(self)
  # everything must scoped under platform-backend for DVP load balancer reqs
  scope '/platform-backend' do
    devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
    get 'admin/dashboard', to: 'admin/dashboard#index'
    resources :consumers, only: [:create]
    resources :github_alerts, only: [:create]
    root to: 'home#index'
    namespace :admin do
      namespace :api do
        namespace :v0 do
          resources :apis do
            collection do
              post :bulk_upload
            end
          end
        end
      end
      namespace :kong do
        namespace :v0 do
          resources :kong_consumers
        end
      end
    end
  end
end
