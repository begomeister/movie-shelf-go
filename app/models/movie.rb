class Movie < ApplicationRecord
  validates :title, presence: true
  validate :unique_movie_titles
  validates :review, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 5.0}

  belongs_to :movie_status
  has_and_belongs_to_many :movie_lists

  def unique_movie_titles
  	current_movies = self.movie_lists.first.movies

    matching_title_movie = current_movies.where("lower(title) = ?", self.title.downcase).first

  	if matching_title_movie.present? && matching_title_movie.id != self.id
  		errors.add(:title, self.title + ": already present")
  	end
  end
end
