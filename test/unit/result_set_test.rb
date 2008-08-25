require File.dirname(__FILE__) + '/../test_helper'

class ResultSetTest < Test::Unit::TestCase
  def test_load_returns_result_set
    posts = Post.find :all, :order => 'title'
    assert ActiveRecord::ResultSet::ResultSetProxy === posts
    assert_equal 2, posts.length
    assert_equal posts(:puppies), posts.first
  end
  
  def test_select
    posts = Post.find :all, :order => 'title'
    assert_equal [], posts.first.comments.select {|c| c.body.empty?}
  end
end