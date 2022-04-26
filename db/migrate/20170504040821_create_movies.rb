class CreateMovies < ActiveRecord::Migration[5.0]
  def change
    create_table :movies do |t|
      t.text :title
      t.text :director
      t.date :release_date
      t.text :runtime
      t.text :writer
      t.text :description
      t.text :genre
      t.text :mpaa_rating
      t.text :production_budget
      t.float :review
      t.references :movie_status, foreign_key: true

      t.timestamps
    end
  end
end
