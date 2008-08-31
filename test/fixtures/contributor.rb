class Contributor <  ActiveRecord::Base
  has_many :contributions
  has_one :profile
end