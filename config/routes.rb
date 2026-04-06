Rails.application.routes.draw do
  devise_for :users

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
  resources :portfolios, only: [ :show ] do
    resources :trades, only: [ :create ]
  end

  root to: "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
