class Users < ActiveRecord::Base
  has_many :recipes, :through => :recipecontains
end