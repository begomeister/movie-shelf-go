# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#Displays the modal with movie information on it
@displayModal = (movieId) ->
  $.get "movies/modalInformation?id=" + movieId, (movie) ->
    	movieUrl = "/movies/" + movie.id;

    	$("#movie-modal-view").click ->
    		  window.location =  movieUrl

    	$("#movie-modal-edit").click ->
    		  window.location = movieUrl + "/edit"

      movie_modal_status = generateMovieStatusButton(movie.id, movie.movie_status.name)
      $("#movie-modal-status").html(movie_modal_status)

      $("#movie-modal-title").text(movie.title)

      $("#movie-modal-description").text(movie.description)

      $("#movie-modal-review").rateYo("option", "rating", review)

      if movie.review > 0
        review = movie.review
      else
        review = 0

      $("#movie-modal-review").rateYo("option", "rating", review)

      $("#movie-modal").modal('toggle')

#Generates the movie status button
@generateMovieStatusButton = (movieId, movieStatus) ->
  if movieStatus == "Watched"
    btnClass = "btn-info"
    $( this ).removeClass("btn-warning")
  else if movieStatus == "Pending Edit"
    link = "/movies/#{movieId}/edit"
    return """<a class='btn btn-sm btn-default movie-status-button' href='#{link}'>Pending Edit</a>"""
  else
    btnClass = "btn-warning"
    $( this ).removeClass("btn-info")

  return """<div class='btn btn-sm #{btnClass} movie-status-button' onclick='toggleMovieStatus(#{movieId}, this)'>#{movieStatus}</div>"""

#Toggles the movie status
@toggleMovieStatus = (movieId, element) ->
  $.post "/movies/#{movieId}/toggle_status", (movie) ->
    statusButton = generateMovieStatusButton(movie.id, movie.movie_status.name)
    $(element).replaceWith(statusButton)
