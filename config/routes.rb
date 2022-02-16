# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/platform-backend/admin/dashboard'), as: 'rootiest_root'

  scope '/platform-backend' do # everything must be scoped under platform-backend for DVP load balancer reqs
    root to: 'home#index'

    mount OkComputer::Engine, at: '/health_check'
    devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

    mount RailsAdmin::Engine => '/admin/rails_admin', as: 'rails_admin'

    mount V0::Base => '/'

    namespace :admin do
      root to: 'dashboard#index'

      resources :dashboard, only: [:index] do
        collection do
          resources :apis, only: [] do
            collection do
              post :bulk_seed
              post :destroy_all
            end
          end

          post 'consumers:migrate', to: 'consumers#load_initial',
                                    as: 'migrate_consumers',
                                    constraints: { migrate: /:migrate/ }
          resources :consumers, only: [] do
            collection do
              post :destroy_all
            end
          end
        end
      end
    end
  end
end
