Rails.application.routes.draw do
  # Defines the root path route ("/")
  root "vehicles#index"

  resources :vehicles do
    resources :maintenance_services, only: [ :new, :create, :edit, :update ]
  end

  # API
  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      resources :vehicles, only: [ :index ]
    end
  end
end
