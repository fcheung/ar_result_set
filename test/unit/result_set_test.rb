require File.dirname(__FILE__) + '/../test_helper'

class ResultSetTest < Test::Unit::TestCase
  def test_truth
    assert_equal 2, Post.count
  end
end