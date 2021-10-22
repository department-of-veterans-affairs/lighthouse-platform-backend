# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  Healthcheck.routes(self)

  scope '/platform-backend' do # everything must be scoped under platform-backend for DVP load balancer reqs
    resources :consumers, only: [:create]
    resources :github_alerts, only: [:create]

    namespace :admin do
      get 'dashboard', to: 'dashboard#index'
      mount Sidekiq::Web => '/sidekiq'

      namespace :api do
        namespace :v0 do
          post 'consumers:migrate', to: 'consumers#load_initial', constraints: { migrate: /:migrate/ }

          resources :apis, only: [:create] do
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
