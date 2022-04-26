# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#Movie Statuses
MovieStatus.create(id: 1, name: "Watched", description: "Movie that has already been watched.")
MovieStatus.create(id: 2, name: "Not Watched", description: "Movie that has not been watched.")
MovieStatus.create(id: 3, name: "Pending Edit", description: "Movie needs to be edited.")

#Dev User
User.create(id: 1, email: "dev@example.com", password: "123", password_confirmation: "123")