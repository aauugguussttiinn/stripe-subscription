Rails.application.routes.draw do
  devise_for :users
  root "static_pages#index"

  namespace :purchase do
    resources :checkouts
  end
  
  resources :subscriptions
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
