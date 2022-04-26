require 'test_helper'
require 'helpers/movies_controller_helpers'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  include MovieHelper

	def setup
		@user = User.create(  email: "user@example.com",
                          password: "foobar",
                          password_confirmation: "foobar")
    sign_in_as(@user)

    movie_list = @user.movie_lists.find_by_name("default")

    @movie = Movie.new(title: "Matrix")
    @movie.movie_status = MovieStatus.first
    @movie.review = 0
    @movie.movie_lists << movie_list
    @movie.save

    if @movie.id.nil?
      raise @movie.errors.full_messages
    end
	end

  test "should get movie paths" do
    get_paths = [ movies_path,
                  movie_path(@movie.id),
                  new_movie_path,
                  edit_movie_path(@movie.id)]

    get_paths.each do |movie_path|
      get movie_path
      assert_response :success
    end
  end

  test "should redirect if not logged in" do
    sign_out_as(@user)

    get_paths = [ movies_path,
                  movie_path(@movie.id),
                  new_movie_path,
                  edit_movie_path(@movie.id)]

    get_paths.each do |movie_path|
      get movie_path
      assert_response :redirect
    end
  end

  test "should not save movie without title" do
    new_movie = generate_movie("", @user)
    assert_not new_movie.save
  end

  test "should not save movie without status" do
    new_movie = generate_movie("test", @user)
    new_movie.movie_status = nil
    assert_not new_movie.save
  end

  test "should not save movie without review" do
    new_movie = generate_movie("test", @user)
    new_movie.review = nil
    assert_not new_movie.save
  end

  test "should not save movie with same title case insensitive" do
    movie_titles = ["Matrix", "MATRIX", "mAtrix", "maTRIx"]

    movie_titles.each do |movie_title|
      new_movie = generate_movie(movie_title, @user)
      assert_not new_movie.save
    end
  end

  test "should edit movie value" do
    @movie.review = 2.0
    @movie.save
    assert @movie.review == 2.0
  end
end
