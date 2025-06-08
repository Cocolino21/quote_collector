Rails.application.routes.draw do
  root 'quotes#index'
  resources :quotes
  get 'random', to: 'quotes#random'
end