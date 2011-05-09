class Tag < ActiveRecord::Base
  has_many :recipetags
  has_many :recipes, :through => :recipetags
  has_many :cookbooks, :through => :cookbooktags
  has_many :tags, :through => :tagsynonyms
  has_many :tags, :through => :autotags
  has_many :autotags
  has_many :tagsynonyms
end


