Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "today#show"

  get "/terms", to: "pages#terms"
  get "/privacy", to: "pages#privacy"
  get "/sentry-test", to: "pages#sentry_test"

  # GoogleのOAuth用設定
  get "login", to: "sessions#new"
  get "auth/:provider/callback", to: "sessions#create"
  get "auth/failure", to: "sessions#failure"
  delete "logout", to: "sessions#destroy"

  resources :trips, only: %i[index new create show edit update destroy] do
    resources :trip_recipients, only: %i[new create update destroy]
  end
  resources :recipients, only: %i[index new create show edit update destroy]
  resources :tags, only: %i[index create edit update destroy]
end
