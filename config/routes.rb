# frozen_string_literal: true

Rails.application.routes.draw do
  Healthcheck.routes(self)
  
  scope '/platform-backend' do # everything must be scoped under platform-backend for DVP load balancer reqs
    get 'admin/dashboard', to: 'admin/dashboard#index'
    
    resources :consumers, only: [:create]
    post 'consumers:migrate', to: 'consumers#load_initial', constraints: { migrate: /:migrate/ }
    get 'consumers/migrations/:id/status', to: 'consumers#migration_status'
    
    resources :github_alerts, only: [:create]
    
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
