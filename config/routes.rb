require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users
  resources :sketches, only: [:index, :new, :create, :show]
  get "about", to: "welcome#about"
  root "welcome#index"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end
end