Rails.application.routes.draw do
  devise_for :admins, path: "admin", only: :sessions
  devise_for :users, controllers: { registrations: "users_registrations" }

  namespace :admin do
    resources :users, only: [ :index, :show, :destroy ]
  end

  post "users/guest_sign_in", to: "guest_sessions#create", as: :guest_sign_in
  get "mypage", to: "users#show", as: :mypage
  resources :users, only: [ :index, :show ]

  resources :posts, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    resources :comments, only: [ :create, :destroy ], module: :posts
  end

  root "homes#top"
  get "about", to: "homes#about"
  get "up", to: "rails/health#show", as: :rails_health_check
end
