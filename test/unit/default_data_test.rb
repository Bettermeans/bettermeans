# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
#

require File.dirname(__FILE__) + '/../test_helper'

class DefaultDataTest < ActiveSupport::TestCase
  include Redmine::I18n
  fixtures :roles
  
  def test_no_data
    assert !Redmine::DefaultData::Loader::no_data?
    Role.delete_all("builtin = 0")
    Tracker.delete_all
    IssueStatus.delete_all
    Enumeration.delete_all
    assert Redmine::DefaultData::Loader::no_data?
  end
  
  def test_load
    # valid_languages.each do |lang|
    #   begin
    #     Role.delete_all("builtin = 0")
    #     Tracker.delete_all
    #     IssueStatus.delete_all
    #     Enumeration.delete_all
    #     assert Redmine::DefaultData::Loader::load(lang)
    #     assert_not_nil DocumentCategory.first
    #     assert_not_nil IssuePriority.first
    #   rescue ActiveRecord::RecordInvalid => e
    #     assert false, ":#{lang} default data is invalid (#{e.message})."
    #   end
    # end
    Role.delete_all("builtin = 0")
    Tracker.delete_all
    IssueStatus.delete_all
    Enumeration.delete_all
    assert Redmine::DefaultData::Loader::load('en')
    assert_not_nil DocumentCategory.first
    assert_not_nil IssuePriority.first
  rescue ActiveRecord::RecordInvalid => e
    assert false, ":#{lang} default data is invalid (#{e.message})."
  end
end
