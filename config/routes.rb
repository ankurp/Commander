require "sidekiq/web"

Rails.application.routes.draw do
  resources :commands, only: [:index, :show, :new, :create, :kill] do
    member do
      delete "kill"
    end
  end
  get "/privacy", to: "home#privacy"
  get "/terms", to: "home#terms"
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  resources :notifications, only: [:index]
  resources :announcements, only: [:index]
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}

  constraints ApplicationHelper::SignedIn.new do
    root to: "commands#index"
  end

  root to: "home#index", as: :logged_out_root
end
