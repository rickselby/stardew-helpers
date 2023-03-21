Rails.application.routes.draw do
  get "/", to: "main#index", as: :root
end
