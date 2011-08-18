# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

# Test case that checks that the testing infrastructure is setup correctly.
class TestingTest < ActiveSupport::TestCase
  def test_working
    assert true
  end

  test "Rails 'test' case syntax" do
    assert true
  end

  test "Generating with object_daddy" do
    assert_difference "IssueStatus.count" do
      IssueStatus.generate!
    end
  end

  should "work with shoulda" do
    assert true
  end

  context "works with a context" do
    should "work" do
      assert true
    end
  end

end
