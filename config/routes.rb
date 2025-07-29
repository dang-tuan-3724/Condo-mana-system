Rails.application.routes.draw do
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check
  # root "rails/health#show"
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
end
