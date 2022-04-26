class MovieListsController < ApplicationController
	before_action :logged_in_user

	def create
		@shelf = current_user.movie_lists.new(movieListParams)

		if @shelf.save
			render :json => @shelf
		else
			render :json => { :errors => @shelf.errors.full_messages }, :status => 422
		end
	end

	def destroy
		@shelf = current_user.movie_lists.find(params[:id])

		if @shelf.name == "default"
			render :json => { :errors => "Default movie shelves are not deleteable." }, :status => 422
			return
		end

		if @shelf.destroy
			render :json => { :message => "Shelf succesfully deleted"}
		else
			render :json => { :errors => @shelf.errors.full_messages }, :status => 422
		end
	end

	# Adds movies to a shelf
	def add_movies_to_shelf
		shelf = MovieList.find(params[:id]) #The current shelf
		new_movie_ids = params[:shelf][:movies] #the movie_ids trying to be added
		shelf_movies = shelf.movies.all #all the movies in the shelf

		# Removes any entries in the new movies if they are already in the shelf
		new_movie_ids.delete_if do |new_movie_id|
			shelf_movies.exists?(new_movie_id)
		end

		# Returns an error if all the movies are already in the list
		if new_movie_ids.count == 0
			render :json => { :errors => "Movies already in list!"}, :status => 422
			return
		end

		# Gets the movie objects from the current user based on the new_movie_ids
		new_movies = current_user.movies.where(id: new_movie_ids).group("id")

		# Adds the movies to the shelf
		if shelf.movies << new_movies
			render :json => { :message => "Movies succesfully added to shelf"}
		else
			render :json => { :errors => shelf.errors.full_messages }, :status => 422
		end
	end

	#removes a movie from the shelf using an ajax calls
	def remove_movie_from_shelf
		shelf = MovieList.find(params[:id])
		movie = Movie.find(params[:movie_id])

		if shelf.movies.delete(movie)
			render :json => { :message => "#{movie.title} succesfully removed from shelf"}
		else
			render :json => { :errors => shelf.errors.full_messages }, :status => 422
		end
	end

	#loads all the shelves except the first one, which is the default shelf
	def load_shelves
		movie_lists = current_user.movie_lists.all_but_first

		respond_to do |format|
      format.json { render json: movie_lists.to_json }
    end
	end

	#Get all movies from a specific shelf id
	def get_movies_by_id
		id = params[:id]
		movies = 	current_user.movie_lists.find_by_id(id)
							.movies.all.select(:id, :title, :director, :release_date, :runtime, :writer, :genre, :movie_status_id)
							.order(:title)

		respond_to do |format|
      format.json { render json: movies.to_json(:include => :movie_status) }
    end
	end

	#retrieves all of the users movies that are NOT in the shelf
	def get_movies_not_in_shelf
		shelf_id = params[:id]
		shelf_movies_ids = MovieList.find(shelf_id).movies.pluck(:id).map(&:to_i)

		movies = 	current_user.movies
							.where.not(id: shelf_movies_ids)
							.group("id")
							.select(:id, :title)

		respond_to do |format|
			format.json { render json: movies.to_json }
		end
	end

	private
		def movieListParams
      params.require(:shelf).permit(:name)
    end
end
