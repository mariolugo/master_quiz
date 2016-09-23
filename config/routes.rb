Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'

  get 'sessions/new'

  root 'home_page#home'
  get '/home', to: 'home_page#home'
  get '/help', to: 'home_page#help'
  get '/signup', to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users
  post '/signup',  to: 'users#create'
  resources :questions

  get '/quiz', to: 'quiz#quiz'
  post '/quiz/check', to: 'quiz#check_answer'
  post '/quiz/next', to: 'quiz#next_question'
  get '/quiz/results/:correct', to: 'quiz#result'
end