# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class SettingTest < ActiveSupport::TestCase
  
  def test_read_default
    assert_equal "Redmine", Setting.app_title
    assert Setting.self_registration?
    assert !Setting.login_required?
  end
  
  def test_update
    Setting.app_title = "My title"
    assert_equal "My title", Setting.app_title
    # make sure db has been updated (INSERT)
    assert_equal "My title", Setting.find_by_name('app_title').value
    
    Setting.app_title = "My other title"
    assert_equal "My other title", Setting.app_title
    # make sure db has been updated (UPDATE)
    assert_equal "My other title", Setting.find_by_name('app_title').value
  end
  
  def test_serialized_setting
    Setting.notified_events = ['issue_added', 'issue_updated', 'news_added']    
    assert_equal ['issue_added', 'issue_updated', 'news_added'], Setting.notified_events
    assert_equal ['issue_added', 'issue_updated', 'news_added'], Setting.find_by_name('notified_events').value
  end
end



# == Schema Information
#
# Table name: settings
#
#  id         :integer         not null, primary key
#  name       :string(255)     default(""), not null
#  value      :text
#  updated_on :datetime
#

