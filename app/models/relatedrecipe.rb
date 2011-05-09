class Relatedrecipe < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :required_recipe, :class_name => 'Recipe'
  has_many   :tags, :through => :required_recipe
end
