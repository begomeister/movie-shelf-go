Rails.application.routes.draw do
  root "static_pages#home"

  #Users
  get 'sign_up', to: "users#new"

  #Sessions
  get 'login', to: "sessions#new"
  delete 'logout', to: "sessions#destroy"

  #Static pages
  get '/home', to: "static_pages#home"
  get '/about', to: "static_pages#about"

  #Movies
  get '/movies/modalInformation', to: "movies#modalInformation"
  post '/movies/:id/toggle_status', to: "movies#toggle_movie_status"
  post '/movies/add_quick', to: "movies#add_quick"

  #Movie Lists
  get '/movie_lists/load_shelves', to: "movie_lists#load_shelves"
  get '/movie_lists/:id/movies', to: "movie_lists#get_movies_by_id"
  get 'movie_lists/:id/not_shelved', to: "movie_lists#get_movies_not_in_shelf"
  post 'movie_lists/:id/add_movies', to: "movie_lists#add_movies_to_shelf"
  delete 'movie_lists/:id/movies/:movie_id', to: "movie_lists#remove_movie_from_shelf"

  resources :movies
  resources :users
  resources :sessions
  resources :movie_lists
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
