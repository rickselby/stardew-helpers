Rails.application.routes.draw do
  root to: redirect("/calendar")

  resources :calendar, only: [:index]
  resources :forage, only: [:index]
  get "map/:name", to: "map#map"
  get "map/:name/:x/:y", to: "map#marker"
  resources :villager, only: [:show]
end
