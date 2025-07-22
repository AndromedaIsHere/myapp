Rails.application.routes.draw do
  devise_for :users
  resources :sketches, only: [:index, :new, :create, :show]
  get "about", to: "welcome#about"
  root "welcome#index"
end
