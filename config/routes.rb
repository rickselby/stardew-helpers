Rails.application.routes.draw do
  root to: redirect("/calendar")
  resources :calendar, only: [:index]
  resources :villager, only: [:show]
end
