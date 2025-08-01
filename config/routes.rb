Rails.application.routes.draw do
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
end
