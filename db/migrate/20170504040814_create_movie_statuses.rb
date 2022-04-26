class CreateMovieStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :movie_statuses do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
