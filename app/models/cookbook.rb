class Cookbook < ActiveRecord::Base
  belongs_to :author
  belongs_to :publisher
  has_many   :recipes, :order => :page, :include => [:recipetags, :relatedrecipes, :userrecipes]
  has_many :cookbooktags, :include => :tag
end
