# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class TrackerTest < ActiveSupport::TestCase
  fixtures :trackers, :workflows

  def test_copy_workflows
    source = Tracker.find(1)
    assert_equal 89, source.workflows.size
    
    target = Tracker.new(:name => 'Target')
    assert target.save
    target.workflows.copy(source)
    target.reload
    assert_equal 89, target.workflows.size
  end
end
