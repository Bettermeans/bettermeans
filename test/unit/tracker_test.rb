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


# == Schema Information
#
# Table name: trackers
#
#  id            :integer         not null, primary key
#  name          :string(30)      default(""), not null
#  is_in_chlog   :boolean         default(FALSE), not null
#  position      :integer         default(1)
#  is_in_roadmap :boolean         default(TRUE), not null
#

