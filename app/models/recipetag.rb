class Recipetag < ActiveRecord::Base
  belongs_to   :recipe
  belongs_to   :tag
  belongs_to   :unit
end
