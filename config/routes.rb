Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication
  get  "/login",    to: "sessions#new",     as: :login
  post "/login",    to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  # Registration
  get  "/register", to: "registrations#new", as: :register
  post "/register", to: "registrations#create"

  # Profile
  get   "/profile",      to: "profiles#show", as: :profile
  get   "/profile/edit", to: "profiles#edit", as: :edit_profile
  patch "/profile",      to: "profiles#update"

  # User loans (Meine Ausleihen)
  get "/my_loans", to: "loans#index", as: :my_loans
  resources :loans, only: [:index] do
    member do
      patch :return_device
    end
  end

  # Devices & Borrowing
  resources :devices, only: [:index, :show] do
    resources :loans, only: [:create]
  end

  # Admin Namespace
  namespace :admin do
    root to: "devices#index"
    resources :devices do
      member do
        patch :toggle_status
      end
    end
    resources :loans, only: [:index] do
      member do
        patch :return_device
      end
    end
    resources :users, only: [:index, :edit, :update] do
      member do
        patch :toggle_role
        patch :toggle_active
      end
    end
    resources :activity_logs, only: [:index]
  end

  # Root
  root to: "devices#index"
end
