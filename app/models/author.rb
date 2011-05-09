class Author < ActiveRecord::Base
  has_many   :cookbooks
end
