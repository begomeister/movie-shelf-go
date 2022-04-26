class AddMovieListMoviesTable < ActiveRecord::Migration[5.0]
  def change
  	create_table :movie_lists_movies do |t|
  		t.references :movie, foreign_key: true
  		t.references :movie_list, foreign_key: true
  	end
  end
end
