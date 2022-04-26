class MoviesController < ApplicationController
  before_action :logged_in_user
  before_action :set_api_key

  def index
    getMovieList
  end

  def show
    @movie = @current_user.get_movie(params[:id])
  end

  #Returns all information from a movie into a json object
  def modalInformation
    movie = @current_user.get_movie(params[:id])

    respond_to do |format|
      format.json { render json: movie.to_json(:include => :movie_status) }
    end
  end

  def new
    @movie = Movie.new

    # Gets the movie title or movie_id if they are present
    autofill_params = {
      movie_title: params[:movie_query].present? ? params[:movie_query][:title] : nil,
      movie_id: params[:movie_id].present? ? params[:movie_id] : nil
    }

    #If a movie title or id is present try to find movie information in MovieDB
    if autofill_params[:movie_title].present? || autofill_params[:movie_id].present?
      #If no information is found, go back
      unless find_movie_info(autofill_params)
        flash.now[:danger] = "No movie found"
        redirect_to root_path
      end
    end
  end

  # Generates a new movie with pre-configured values for the "quick add" option via AJAX calls
  def add_quick
    @movie = Movie.new(movieParams)
    movie_status = MovieStatus.find_by(name: "Pending Edit")
    @movie.movie_status = movie_status
    @movie.review = 0.0
    add_to_default_movie_list

    if @movie.save
      respond_to do |format|
        format.json { render json: { message: "Movie \"" + @movie.title + "\" succesfully added!", id: @movie.id, movie_title: @movie.title}.to_json }
      end
    else
      respond_to do |format|
        format.json { render json: { :errors => @movie.errors.full_messages }, :status => 422 }
      end
    end
  end

  def create
    @movie = Movie.new(movieParams)
    add_to_default_movie_list

    if @movie.save
      flash.now[:success] = "Movie \"" + @movie.title + "\" succesfully added!"

      redirect_to movie_path(id: @movie.id)
    else
      flash.now[:danger] = @movie.errors.full_messages
      @movie = Movie.new
      render 'movies/new'
    end
  end

  def edit
    @movie = @current_user.get_movie(params[:id])

    # Gets the movie title or movie_id if they are present
    autofill_params = {
      movie_title: params[:title].present? ? params[:title] : nil,
      movie_id: params[:movie_id].present? ? params[:movie_id] : nil
    }

    #If autofill parameter was set, try to find data for movie in MovieDB, and set status to not watched
    if autofill_params[:movie_title].present? || autofill_params[:movie_id].present?
      if find_movie_info(autofill_params)
        flash.now[:success] = "Movie autofill data found!"
        render 'edit'
      else
        flash.now[:danger] = "Movie autofill data not found."
        render 'edit'
      end
    end
  end

  def update
    @movie = @current_user.get_movie(params[:id])

    if @movie.update_attributes(movieParams)
      flash.now[:success] = "Movie succesfully updated!"
      redirect_to @movie
    else
      flash.now[:danger] = @movie.errors.full_messages
      render 'edit'
    end
  end

  def destroy
    @movie = @current_user.get_movie(params[:id])

    if @movie.destroy
      flash.now[:success] = "Movie deleted"
    else
      flash.now[:danger] = "Unable to delete movie."
    end

    redirect_to ''
  end

  #Toggles movie status from Watched to Not Watched and vice-versa via AJAX
  def toggle_movie_status
    @movie = @current_user.get_movie(params[:id])
    if @movie.movie_status.name == "Watched"
      movie_status = MovieStatus.find_by_name("Not Watched")
    else
      movie_status = MovieStatus.find_by_name("Watched")
    end

    @movie.movie_status = movie_status
    if @movie.save
      respond_to do |format|
        format.json { render json: {movie_status: @movie.movie_status, id:  @movie.id}.to_json }
      end
    end
  end

  private
    def movieParams
      params.require(:movie).permit(:title, :director, :release_date,
                                    :runtime, :writer, :genre, :description,
                                    :review, :movie_status_id, :mpaa_rating, :production_budget)
    end

    # Sets the api key for the movie db
    def set_api_key
      Tmdb::Api.key( ENV["MOVIE_DB_API_KEY"] )
    end

    # Finds movie information
    # If movie title is present it finds the first result.
    # Otherwise it uses a movie id to immediatelly autofill the search data
    # Returns true or false based on success
    def find_movie_info(autofill_params)
      movie_id = autofill_params[:movie_id]
      movie_title = autofill_params[:movie_title]

      # If no movie id is present it finds one from the title, and sets a @movie_search_results variable for suggestions
      unless movie_id.present?
        @movie_search_results = get_api_movie_search(movie_title)
        unless @movie_search_results.present?
          return false
        end

        #Gets the id from the first result and discards it from the array, so it doesn't show up in the suggested results
        movie_id = @movie_search_results.shift.id
      end

      #Fill @movie object with movie id from the API
      unless get_movie_data(movie_id)
        flash.now[:warning] = "No Movie Information found. Invalid id."
        return false
      end

      #return first five results from the search for suggestion or true
      return true
    end

    # Gets the movies from a search on the API
    # Returns false if no information was found, returns search results if information was found
    def get_api_movie_search(movie_title)
      movie_search_results = Tmdb::Movie.find(movie_title)

      unless movie_search_results.present?
        flash.now[:warning] = "No Movie Information found. Check if movie title is spelled correctly, or continue without movie title for custom entry."
        return false
      end

      #Get movie id from the api
      return movie_search_results.first(6)
    end

    # Gets movie data from The MovieDB based on the given id and adds it to the @movie object
    # Returns true once completed
    # Return false if no movie info is found
    # Check https://developers.themoviedb.org/3/getting-started for more info
    # TODO use OpenStruct to convert this to an object instead of hash?
    def get_movie_data(movie_id)
      # Get relevant information from movie
      movie_details = Tmdb::Movie.detail(movie_id)

      # Checking if the first info found exists, if not the other ones won't work either
      unless movie_details.present?
        return false
      end

      movie_credits = Tmdb::Movie.credits(movie_id)
      movie_crew = movie_credits["crew"]
      movie_releases = Tmdb::Movie.releases(movie_id)

      #Insert relevant info into movie object
      insertMovieDetails(movie_details)
      insertMovieCrew(movie_crew)
      insertMovieReleases(movie_releases)

      return true
    end

    #Inserts alls movie details from the api to the movie object
    def insertMovieDetails(movie_details)
      @movie.title = movie_details["title"]
      @movie.release_date = movie_details["release_date"]
      @movie.runtime = movie_details["runtime"].to_s + " minutes"
      @movie.description = movie_details["overview"]

      #requires number converted to currency
      @movie.production_budget = ActionController::Base.helpers.number_to_currency(movie_details["budget"])

      #parses movie genres into a single text
      @movie.genre = parseMovieInfoArrays(movie_details["genres"])

      #POSTER PATH
      #https://image.tmdb.org/t/p/original/
    end

    #Inserts all movie crew information from the api to the movie object
    def insertMovieCrew(movie_crew)
      # Movie directors
      movie_directors = movie_crew.select{ |crew| crew["department"] == "Directing" }
      @movie.director = parseMovieInfoArrays(movie_directors)
      #@movie.director = movie_directors["name"]

      # Movie writers
      movie_writers = movie_crew.select{ |crew| crew["department"] == "Writing" }
      @movie.writer = parseMovieInfoArrays(movie_writers)
    end

    #Inserts all movie release information from the api to the movie object
    def insertMovieReleases(movie_releases)
      release_us = movie_releases["countries"].detect{ |release| release["iso_3166_1"] == "US" }
      unless release_us.nil?
        mpaa_rating = release_us["certification"]
        @movie.mpaa_rating = mpaa_rating
      end
    end

    #Adds movie to the default list for the current user
    def add_to_default_movie_list
      movie_list = current_user.movie_lists.first
      @movie.movie_lists << movie_list
    end

    #Parses multiple entries into a single string with "|" being the separator
    def parseMovieInfoArrays(array_items)
      unless array_items.empty?
        result = array_items.shift["name"]
        array_items.each do |item|
          result += " | #{item['name']}"
        end

        return result
      end
    end
end
