Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, skip: [ :sessions, :passwords, :confirmations, :registrations ]

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      resources :categories
    end
  end

  # Custom OAuth routes for documentation
  post "/oauth/token/issue", to: "oauth/tokens#issue"
  post "/oauth/token/refresh", to: "oauth/tokens#refresh"
  post "/oauth/revoke", to: "oauth/tokens#revoke"

  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
