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
  
  def test_load_associations
    posts = Post.find :all, :order => 'title'
    posts.load :comments
    assert_no_queries do
      assert_equal 3, posts.first.comments.length
    end
  end
  
  def test_sets_result_set
    posts = Post.find :all, :order => 'title'
    posts.each {|p| assert_equal posts.object_id, p.result_set.object_id}
  end
  
  def test_loads_other_association
    posts = Post.find :all, :order => 'title'
    posts[0].comments.length
    assert_no_queries do
      posts[1].comments.length
    end
  end
  
  
  def test_has_one_through
    posts = Post.find :all, :order => 'title'
    assert_nothing_raised {posts.first.star_contributor}
  end
end