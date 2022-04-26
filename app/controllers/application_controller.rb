class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  def getMovieList
  	#Eventually this will be an ajax call with the movie_lists id as a parameter. Defaulting to the first one
  	if logged_in?
  		list = @current_user.movie_lists.first
  		@movie_list = list.movies.all.select(:id, :title, :director, :release_date, :runtime, :writer, :genre, :movie_status_id).order(:title)
  	end
  end
end
