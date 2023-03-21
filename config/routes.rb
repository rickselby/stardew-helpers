Rails.application.routes.draw do
  get "/", to: "main#index", as: :root
  resources :calendar, only: [:index]
  resources :villager, only: [:show]
end
