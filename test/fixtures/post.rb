class Post < ActiveRecord::Base
  has_many :comments
  has_many :last_comments, :limit => 2, :class_name => 'Comment'
  has_many :contributions
  has_many :contributors, :through => :contributions
  has_one :star_contributor, :through => :contributions, :conditions => {:star => 1}, :source => :contributor, :class_name => 'Contributor'
  has_and_belongs_to_many :categories
end