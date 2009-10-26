# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class TimeEntryActivityTest < ActiveSupport::TestCase
  fixtures :enumerations, :time_entries

  def test_should_be_an_enumeration
    assert TimeEntryActivity.ancestors.include?(Enumeration)
  end
  
  def test_objects_count
    assert_equal 3, TimeEntryActivity.find_by_name("Design").objects_count
    assert_equal 1, TimeEntryActivity.find_by_name("Development").objects_count
  end

  def test_option_name
    assert_equal :enumeration_activities, TimeEntryActivity.new.option_name
  end
end

