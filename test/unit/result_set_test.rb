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
    
    posts.load :comments
    assert_no_queries do
      assert_equal 3, posts.first.comments.length
    end
  end
  
  def test_sets_result_set
    posts = Post.find :all, :order => 'title'
    posts.each {|p| assert_equal posts.object_id, p.result_set.object_id}
  end
  
  def test_loads_has_many
    posts = Post.find :all, :order => 'title'
    assert_equal 3, posts[0].comments.length
    assert_no_queries do
      assert_equal 3, posts[1].comments.length
    end
  end
  
  
  def test_has_one_through_other_records_loaded
    posts = Post.find :all, :order => 'title desc'
    posts.first.star_contributor
    assert_no_queries {assert_equal 'bob', posts[1].star_contributor.name}
  end
  
  def test_has_one_through_record_loaded
    posts = Post.find :all, :order => 'title asc'
    assert_equal contributors(:bob), posts.first.star_contributor
  end
end