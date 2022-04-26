class User < ApplicationRecord
  attr_accessor :password

  before_save :encrypt_password

  after_create :generate_movie_list

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,       presence: true,
                          length: { maximum: 255 },
                          uniqueness: {case_sensitive: false},
                          format: { with: VALID_EMAIL_REGEX }

  validates :password, presence: true, confirmation: true

  has_many :movie_lists, dependent: :destroy
  has_many :movies, through: :movie_lists

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  #get movie
  def get_movie(id)
    self.movies.find(id)
  end

  private
    #generates a generic default movie list
    def generate_movie_list
      self.movie_lists.create(:name => "default")
    end

    #destroys all associated movies
    def destroy_movie_shelves
      self.movie_lists.destroy
    end
end
