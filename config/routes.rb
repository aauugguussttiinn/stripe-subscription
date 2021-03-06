Rails.application.routes.draw do
  devise_for :users
  root "static_pages#index"

  resources :billings, only: :create

  namespace :purchase do
    resources :checkouts
  end

  get "success", to: "purchase/checkouts#success"
  
  resources :subscriptions
  resources :webhooks, only: :create
  
end
