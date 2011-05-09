class Recipe < ActiveRecord::Base
  belongs_to :cookbook
  has_many :tags, :through => :recipetags
  has_many :recipetags, :include => [:unit, :tag]
  has_many :relatedrecipes, :include => [:recipe, :required_recipe, {:required_recipe => :tags}]
  has_many :userrecipes
  has_one  :neededrecipe, :class_name => 'Relatedrecipe', :foreign_key => 'required_recipe_id'
  has_many :recipe_photos
end
