class Unit < ActiveRecord::Base
  has_many :recipetags
  has_many :recipes, :through => :recipetags
end
