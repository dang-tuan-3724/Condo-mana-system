Rails.application.routes.draw do

  get "static_pages/home"
  get "up" => "rails/health#show", as: :rails_health_check
  root "static_pages#home"
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  devise_for :users

  # Temporary redirect for GET sign_out requests
  # get "/users/sign_out", to: redirect("/")
  resources :bookings
  resources :users, path: "members"
  resources :facilities
  resources :units
  resources :unit_members, only: [ :create, :destroy ]
  resources :condos
end
