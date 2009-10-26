# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class IssueCategoryTest < ActiveSupport::TestCase
  fixtures :issue_categories, :issues

  def setup
    @category = IssueCategory.find(1)
  end
  
  def test_destroy
    issue = @category.issues.first
    @category.destroy
    # Make sure the category was nullified on the issue
    assert_nil issue.reload.category
  end
  
  def test_destroy_with_reassign
    issue = @category.issues.first
    reassign_to = IssueCategory.find(2)
    @category.destroy(reassign_to)
    # Make sure the issue was reassigned
    assert_equal reassign_to, issue.reload.category
  end
end
