class MovieList < ApplicationRecord
	validates :name, presence: true, :on => :create
	validate :unique_movie_list_names, :on => :create

	has_and_belongs_to_many :movies
	belongs_to :user

	scope :all_but_first, -> { order(created_at: :asc)[1..-1] }

	private
		def unique_movie_list_names
	  	user = self.user

	  	if user.movie_lists.where("lower(name) = ?", self.name.downcase).exists?
	  		errors.add(:name, self.name + ": already present")
	  	end
	  end
end
