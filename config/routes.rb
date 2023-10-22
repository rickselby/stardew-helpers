Rails.application.routes.draw do
  root to: redirect("/calendar")

  resources :calendar, only: [:index]
  resources :forage, only: [:index]
  get "map/:name/:x/:y", to: "map#show"
  resources :villager, only: [:show]
end
