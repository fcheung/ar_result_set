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
    assert_equal 3, posts.first.comments.length
    assert_no_queries do
      assert_equal 3, posts[1].comments.length
    end
  end
  
  def test_has_one_through_single_records_loaded
    post = Post.find :first, :order => 'title desc'
    post.star_contributor #assert no infinite recursion
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
  
  def test_dont_load_limited_associations
    posts = Post.find :all, :order => 'title asc'
    assert_equal 2, posts.first.last_comments.length
  end
  
  def test_belongs_to
    contributions = Contribution.find :all
    assert_equal contributors(:bob), contributions.first.contributor
    assert_no_queries do
      assert_equal contributors(:bob), contributions[1].contributor
    end
  end
  
  def test_has_one
    contributors = Contributor.find :all, :order => 'name asc'
    profiles(:bob)
    assert_equal profiles(:fred), contributors[1].profile
    assert_no_queries do
      assert_equal profiles(:bob), contributors.first.profile
      assert_nil contributors[2].profile
    end
  end
  
  def test_has_and_belongs_to_many
    posts = Post.find :all, :order => 'title desc'
    assert_equal categories(:general, :public), posts.first.categories
    categories(:pets)
    assert_no_queries do
      assert_equal [categories(:pets)], posts[1].categories
    end
  end
  
  def test_has_many_through
    posts = Post.find :all, :order => 'title desc'
    assert_equal [contributors(:bob)], posts.first.contributors
    assert_no_queries do
      assert_equal [contributors(:bob)], posts[1].contributors
    end
  end
  
  def test_nested_load
    posts = Post.find :all, :order => 'title desc'
    assert_equal profiles(:bob), posts.first.contributors[0].profile
    assert_no_queries do
      assert_equal profiles(:bob), posts[1].contributors[0].profile
    end
  end
  
  def test_detach
    posts = Post.find :all, :order => 'title desc'
    result_set =  posts.first.result_set
    post_to_detach = posts.first

    assert result_set.include?(post_to_detach)
    assert_not_nil post_to_detach.result_set
    
    post_to_detach.detach!
    
    assert_nil post_to_detach.result_set
    assert !result_set.include?(post_to_detach)
  end
end