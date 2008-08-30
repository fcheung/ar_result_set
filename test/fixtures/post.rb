class Post < ActiveRecord::Base
  has_many :comments
  has_many :contributions
  has_one :star_contributor, :through => :contributions, :conditions => {:star => 1}, :source => :contributor, :class_name => 'Contributor'
end