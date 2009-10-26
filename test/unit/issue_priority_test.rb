# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class IssuePriorityTest < ActiveSupport::TestCase
  fixtures :enumerations, :issues

  def test_should_be_an_enumeration
    assert IssuePriority.ancestors.include?(Enumeration)
  end
  
  def test_objects_count
    # low priority
    assert_equal 5, IssuePriority.find(4).objects_count
    # urgent
    assert_equal 0, IssuePriority.find(7).objects_count
  end

  def test_option_name
    assert_equal :enumeration_issue_priorities, IssuePriority.new.option_name
  end
end

