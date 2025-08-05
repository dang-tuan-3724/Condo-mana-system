Rails.application.routes.draw do
  get "unit_members/create"
  get "unit_members/destroy"
  get "units/index"
  get "units/show"
  get "units/new"
  get "units/create"
  get "units/edit"
  get "units/update"
  get "units/destroy"
  get "facilities/index"
  get "facilities/show"
  get "facilities/new"
  get "facilities/edit"
  get "static_pages/home"
  get "up" => "rails/health#show", as: :rails_health_check
  root "static_pages#home"
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  devise_for :users

  # Temporary redirect for GET sign_out requests
  # get "/users/sign_out", to: redirect("/")

  resources :users, path: "members"
  resources :facilities
  resources :units
  resources :unit_members, only: [ :create, :destroy ]
end
