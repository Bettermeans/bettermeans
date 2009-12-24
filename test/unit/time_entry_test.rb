# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class TimeEntryTest < ActiveSupport::TestCase
  fixtures :issues, :projects, :users, :time_entries

  def test_hours_format
    assertions = { "2"      => 2.0,
                   "21.1"   => 21.1,
                   "2,1"    => 2.1,
                   "1,5h"   => 1.5,
                   "7:12"   => 7.2,
                   "10h"    => 10.0,
                   "10 h"   => 10.0,
                   "45m"    => 0.75,
                   "45 m"   => 0.75,
                   "3h15"   => 3.25,
                   "3h 15"  => 3.25,
                   "3 h 15"   => 3.25,
                   "3 h 15m"  => 3.25,
                   "3 h 15 m" => 3.25,
                   "3 hours"  => 3.0,
                   "12min"    => 0.2,
                  }
    
    assertions.each do |k, v|
      t = TimeEntry.new(:hours => k)
      assert_equal v, t.hours, "Converting #{k} failed:"
    end
  end
  
  def test_hours_should_default_to_nil
    assert_nil TimeEntry.new.hours
  end
end


# == Schema Information
#
# Table name: time_entries
#
#  id          :integer         not null, primary key
#  project_id  :integer         not null
#  user_id     :integer         not null
#  issue_id    :integer
#  hours       :float           not null
#  comments    :string(255)
#  activity_id :integer         not null
#  spent_on    :date            not null
#  tyear       :integer         not null
#  tmonth      :integer         not null
#  tweek       :integer         not null
#  created_on  :datetime        not null
#  updated_on  :datetime        not null
#

