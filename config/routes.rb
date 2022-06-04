Rails.application.routes.draw do
  devise_for :users
  root "static_pages#index"

  namespace :purchase do
    resources :checkouts
  end
  
  resources :subscriptions
  get "success", to: "purchase/checkouts#success"
  
end
