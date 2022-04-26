module MoviesHelper
  #Generates the links and posters from a list of movies generated from the movie db api
  def print_movie_suggestions_posters(movies, page)
    output = ""

    movies.each do |movie|
      if( page == "Edit - " )
        #output += "<a href='' data-toggle='' title='#{movie.title}'>" + poster_image + "</a>"
        link = "onclick='autofillMovie(#{movie.id})'"
      elsif( page == "New Movie - " )
        #output = link_to( movie_title, new_movie_path( movie_id: movie_result.id ) )
        link = "href='" + new_movie_path( movie_id: movie.id) + "'"
      end

      #movie_title =  "#{movie_result.title} (#{movie_result.release_date[0..3]})"
      tooltip_movie_title = "#{movie.title} (#{movie.release_date[0..3]})"
      poster_image = "<img class='movie-poster' src='https://image.tmdb.org/t/p/original#{movie.poster_path}' alt='#{tooltip_movie_title}'>"
      output += "<a #{link} data-toggle='tooltip' data-placement='bottom' data-container='body' title='#{tooltip_movie_title}'>" + poster_image + "</a>"
    end

    return output.html_safe
  end
end
