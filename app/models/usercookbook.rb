class Usercookbook < ActiveRecord::Base
  has_many   :cookbooks
  has_many   :users
end
