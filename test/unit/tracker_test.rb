# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
#

require File.dirname(__FILE__) + '/../test_helper'

class TrackerTest < ActiveSupport::TestCase
  fixtures :trackers, :workflows, :issue_statuses, :roles

  def test_copy_workflows
    source = Tracker.find(1)
    assert_equal 89, source.workflows.size

    target = Tracker.new(:name => 'Target')
    assert target.save
    target.workflows.copy(source)
    target.reload
    assert_equal 89, target.workflows.size
  end

  def test_issue_statuses
    tracker = Tracker.find(1)
    Workflow.delete_all
    Workflow.create!(:role_id => 1, :tracker_id => 1, :old_status_id => 2, :new_status_id => 3)
    Workflow.create!(:role_id => 2, :tracker_id => 1, :old_status_id => 3, :new_status_id => 5)

    assert_kind_of Array, tracker.issue_statuses
    assert_kind_of IssueStatus, tracker.issue_statuses.first
    assert_equal [2, 3, 5], Tracker.find(1).issue_statuses.collect(&:id)
  end

  def test_issue_statuses_empty
    Workflow.delete_all("tracker_id = 1")
    assert_equal [], Tracker.find(1).issue_statuses
  end
end



# == Schema Information
#
# Table name: trackers
#
#  id                 :integer         not null, primary key
#  name               :string(30)      default(""), not null
#  is_in_chlog        :boolean         default(FALSE), not null
#  position           :integer         default(1)
#  is_in_roadmap      :boolean         default(TRUE), not null
#  for_credits_module :boolean         default(FALSE)
#

