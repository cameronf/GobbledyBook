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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110130220649) do

  create_table "authors", :force => true do |t|
    t.text "name", :limit => 255
  end

  create_table "autotags", :force => true do |t|
    t.integer "tag_id"
    t.integer "autotag_id"
  end

  add_index "autotags", ["tag_id"], :name => "tags_id"

  create_table "cookbooks", :force => true do |t|
    t.text    "title",           :limit => 255
    t.integer "publisher_id"
    t.integer "author_id"
    t.text    "ISBN",            :limit => 255
    t.integer "isvisible",       :limit => 1
    t.integer "relatedto"
    t.date    "publicationdate"
    t.text    "bookbinding",     :limit => 255
    t.decimal "rating",                         :precision => 2, :scale => 1
    t.date    "lastrating"
  end

  add_index "cookbooks", ["author_id"], :name => "authors_id"

  create_table "cookbooktags", :force => true do |t|
    t.integer "tag_id"
    t.integer "cookbook_id"
  end

  add_index "cookbooktags", ["cookbook_id"], :name => "cookbooks_id"
  add_index "cookbooktags", ["tag_id"], :name => "tags_id"

  create_table "ingredients", :force => true do |t|
    t.text "name", :limit => 255
  end

  create_table "publishers", :force => true do |t|
    t.text "name"
    t.text "displayname"
  end

  create_table "recipe_photos", :force => true do |t|
    t.integer  "recipe_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipecontains", :id => false, :force => true do |t|
    t.integer "recipe_id"
    t.integer "ingredient_id"
  end

  create_table "recipes", :force => true do |t|
    t.text    "name",        :limit => 255
    t.integer "page"
    t.integer "cookbook_id"
    t.integer "user_id"
    t.text    "quantity"
    t.boolean "isVegan",                    :default => false, :null => false
    t.boolean "isOvo",                      :default => false
    t.boolean "isGF",                       :default => false
  end

  add_index "recipes", ["isGF"], :name => "isGF"
  add_index "recipes", ["isOvo"], :name => "isOvo"
  add_index "recipes", ["isVegan"], :name => "isVegan"

  create_table "recipetags", :force => true do |t|
    t.integer "recipe_id"
    t.integer "tag_id"
    t.integer "unit_id"
    t.text    "amount",    :limit => 255
  end

  add_index "recipetags", ["recipe_id"], :name => "recipes_id"
  add_index "recipetags", ["tag_id"], :name => "tags_id"

  create_table "relatedrecipes", :force => true do |t|
    t.integer "recipe_id"
    t.integer "required_recipe_id"
  end

  add_index "relatedrecipes", ["recipe_id"], :name => "recipes_id"
  add_index "relatedrecipes", ["required_recipe_id"], :name => "related_recipe"

  create_table "searchqueries", :force => true do |t|
    t.text    "querystring", :limit => 255
    t.integer "count",                      :default => 0, :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tags", :force => true do |t|
    t.text    "name"
    t.boolean "ingredient", :default => false, :null => false
    t.boolean "dietary",    :default => false, :null => false
    t.boolean "course",     :default => false, :null => false
    t.boolean "meta",       :default => false, :null => false
    t.boolean "origin",     :default => false, :null => false
    t.boolean "cooktime",   :default => false, :null => false
  end

  add_index "tags", ["cooktime"], :name => "cooktime"
  add_index "tags", ["course"], :name => "course"
  add_index "tags", ["dietary"], :name => "dietary"
  add_index "tags", ["ingredient"], :name => "ingredient"
  add_index "tags", ["meta"], :name => "meta"
  add_index "tags", ["origin"], :name => "origin"

  create_table "tagsynonyms", :force => true do |t|
    t.integer "tag_id"
    t.integer "sameas_id"
  end

  add_index "tagsynonyms", ["sameas_id"], :name => "sameas_id"
  add_index "tagsynonyms", ["tag_id"], :name => "tags_id"

  create_table "units", :force => true do |t|
    t.text "unit"
    t.text "abbreviation"
  end

  create_table "usercookbooks", :force => true do |t|
    t.integer "user_id"
    t.integer "cookbook_id"
    t.boolean "owns",        :default => false, :null => false
    t.boolean "wishlist",    :default => false, :null => false
  end

  add_index "usercookbooks", ["cookbook_id"], :name => "cookbooks_id"
  add_index "usercookbooks", ["user_id"], :name => "users_id"

  create_table "userrecipes", :force => true do |t|
    t.integer "user_id"
    t.integer "recipe_id"
    t.integer "rating",     :limit => 1
    t.text    "comments"
    t.boolean "stickynote"
  end

  add_index "userrecipes", ["recipe_id"], :name => "recipe_id"
  add_index "userrecipes", ["user_id"], :name => "user_id"

  create_table "users", :force => true do |t|
    t.text     "nickname"
    t.integer  "banned",               :limit => 1,   :default => 0
    t.integer  "fb_id",                :limit => 8
    t.boolean  "tutorial",                            :default => false, :null => false
    t.string   "email",                               :default => "",    :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",    :null => false
    t.string   "password_salt",                       :default => "",    :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["fb_id"], :name => "fb_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "usersCopy", :force => true do |t|
    t.text    "nickname"
    t.integer "banned",   :limit => 1, :default => 0
    t.integer "fb_id",    :limit => 8
    t.boolean "tutorial",              :default => false, :null => false
  end

  add_index "usersCopy", ["fb_id"], :name => "fb_id"

end
