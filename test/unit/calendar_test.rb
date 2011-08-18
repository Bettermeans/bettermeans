# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class CalendarTest < ActiveSupport::TestCase
  
  def test_monthly
    c = Redmine::Helpers::Calendar.new(Date.today, :fr, :month)
    assert_equal [1, 7], [c.startdt.cwday, c.enddt.cwday]
    
    c = Redmine::Helpers::Calendar.new('2007-07-14'.to_date, :fr, :month)
    assert_equal ['2007-06-25'.to_date, '2007-08-05'.to_date], [c.startdt, c.enddt]   
     
    c = Redmine::Helpers::Calendar.new(Date.today, :en, :month)
    assert_equal [7, 6], [c.startdt.cwday, c.enddt.cwday]
  end

  def test_weekly
    c = Redmine::Helpers::Calendar.new(Date.today, :fr, :week)
    assert_equal [1, 7], [c.startdt.cwday, c.enddt.cwday]
    
    c = Redmine::Helpers::Calendar.new('2007-07-14'.to_date, :fr, :week)
    assert_equal ['2007-07-09'.to_date, '2007-07-15'.to_date], [c.startdt, c.enddt]

    c = Redmine::Helpers::Calendar.new(Date.today, :en, :week)
    assert_equal [7, 6], [c.startdt.cwday, c.enddt.cwday]
  end
end
