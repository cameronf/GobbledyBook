class RecipeContains < ActiveRecord::Base
  belongs_to   :ingredients
  belongs_to   :recipes
end