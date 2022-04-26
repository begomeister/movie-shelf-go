module MovieHelper
	def generate_movie(movie_title, user)
		movie = Movie.new( title: movie_title)
    movie.movie_lists << user.movie_lists.first
    movie.movie_status = MovieStatus.first
		movie.review = 3.0

    return movie
	end
end
