Rails.application.routes.draw do
  get "stocks/index"
  get "stocks/show"
  devise_for :users

  resources :stocks, only: [ :index, :show ] do
    member     { get :ohlcv }
    collection { get :prices }
  end
  resources :leagues, only: [ :index, :show, :new, :create, :destroy ] do
    member do
      post :invite
    end
    collection do
      get  :join
      post :join
    end
  end

  resources :notifications, only: [] do
    collection { patch :mark_read }
  end
  resources :friendships, only: [ :index, :create, :update, :destroy ]
  resources :chatrooms, only: [ :index ] do
    resources :messages, only: [ :create ]
  end

  namespace :chat_widget do
    get  :friends,      to: "base#friends"
    get  :conversation, to: "base#conversation"
    patch :mark_read,   to: "base#mark_read"
  end
  resources :portfolios, only: [ :show ] do
    resources :trades, only: [ :create, :update ] do
      member { patch :cancel }
      collection { post :check_tp_sl }
    end
  end

  root to: "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
