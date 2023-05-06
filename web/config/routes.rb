# frozen_string_literal: true

Rails.application.routes.draw do
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/failure'

  post '/login', to: 'sessions#new', as: :login
  get '/logout', to: 'sessions#destroy', as: :logout

  match '/auth/:provider/callback', to: 'sessions#create', via: %i[get post]
  match '/auth/failure', to: 'sessions#failure', via: %i[get post]

  get "/api", to: "application#api"
  get "/settings", to: "application#settings"

  resources :users
  resources :reminders
  resources :triggers
  resources :issues
  resources :highlights
  resources :linkeds
  resources :trophies

  scope "/api/v1", defaults: { format: :json } do
    resources :reminders
    resources :triggers
    resources :issues
    resources :highlights
    resources :linkeds
    resources :trophies
  end

  root 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
