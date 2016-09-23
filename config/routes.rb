Rails.application.routes.draw do

  root 'home_page#home'
  get '/home', to: 'home_page#home'
  get '/help', to: 'home_page#help'
  get '/signup', to: 'users#new'

  resources :users
  post '/signup',  to: 'users#create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
