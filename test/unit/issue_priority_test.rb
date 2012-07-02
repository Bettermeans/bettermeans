# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
#

require File.dirname(__FILE__) + '/../test_helper'

class IssuePriorityTest < ActiveSupport::TestCase
  fixtures :enumerations, :issues

  def test_should_be_an_enumeration
    assert IssuePriority.ancestors.include?(Enumeration)
  end

  def test_objects_count
    # low priority
    assert_equal 6, IssuePriority.find(4).objects_count
    # urgent
    assert_equal 0, IssuePriority.find(7).objects_count
  end

  def test_option_name
    assert_equal :enumeration_issue_priorities, IssuePriority.new.option_name
  end
end



# == Schema Information
#
# Table name: enumerations
#
#  id         :integer         not null, primary key
#  opt        :string(4)       default(""), not null
#  name       :string(30)      default(""), not null
#  position   :integer         default(1)
#  is_default :boolean         default(FALSE), not null
#  type       :string(255)
#  active     :boolean         default(TRUE), not null
#  project_id :integer
#  parent_id  :integer
#

