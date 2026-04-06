Rails.application.routes.draw do
  get "stocks/index"
  get "stocks/show"
  devise_for :users

  resources :stocks, only: [:index, :show]
  resources :leagues, only: [ :index, :show, :new, :create, :destroy ] do
    member do
      post :invite
    end
    collection do
      get  :join
      post :join
    end
  end

  resources :friendships, only: [ :index, :create, :update, :destroy ]
  root to: "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
