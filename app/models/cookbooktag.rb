class Cookbooktag < ActiveRecord::Base
  belongs_to   :cookbook
  belongs_to   :tag
end
