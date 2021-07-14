# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  get 'admin/dashboard', to: 'admin/dashboard#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post '/github', to: 'github#alert'
  resources :consumers
end
