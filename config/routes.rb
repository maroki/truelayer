Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"

  # post 'truelayer/initiate_payment', to: 'truelayer#initiate_payment'
  # get 'truelayer/callback', to: 'truelayer#callback'


  get '/truelayer/authorize', to: 'truelayer#authorize'
  get '/truelayer/callback', to: 'truelayer#callback'
  post '/truelayer/callback', to: 'truelayer#callback'

  resources :payments, only: [:new, :create, :show]
end
