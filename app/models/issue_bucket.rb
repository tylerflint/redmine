class IssueBucket < ActiveRecord::Base
  has_many :issues
end
