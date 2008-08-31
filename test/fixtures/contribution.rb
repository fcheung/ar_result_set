class Contribution < ActiveRecord::Base
  belongs_to :post
  belongs_to :contributor
end