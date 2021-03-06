# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170517200356) do

  create_table "movie_lists", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_movie_lists_on_user_id"
  end

  create_table "movie_lists_movies", force: :cascade do |t|
    t.integer "movie_id"
    t.integer "movie_list_id"
    t.index ["movie_id"], name: "index_movie_lists_movies_on_movie_id"
    t.index ["movie_list_id"], name: "index_movie_lists_movies_on_movie_list_id"
  end

  create_table "movie_statuses", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "movies", force: :cascade do |t|
    t.text     "title"
    t.text     "director"
    t.date     "release_date"
    t.text     "runtime"
    t.text     "writer"
    t.text     "description"
    t.text     "genre"
    t.text     "mpaa_rating"
    t.text     "production_budget"
    t.float    "review"
    t.integer  "movie_status_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["movie_status_id"], name: "index_movies_on_movie_status_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
