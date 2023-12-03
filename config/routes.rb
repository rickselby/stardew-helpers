# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect("/calendar")

  resources :calendar, only: [:index]
  resources :forage, only: [:index]
  get "map/marker", to: "map#marker"
  get "map/:name", to: "map#map"
  get "map/:name/:x/:y", to: "map#map_with_marker"
  resources :villager, only: [:show]
  resources :locations, only: %i[index create] unless Rails.env.production?
end
