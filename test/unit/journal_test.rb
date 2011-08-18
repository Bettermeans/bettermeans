# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class JournalTest < ActiveSupport::TestCase
  fixtures :issues, :issue_statuses, :journals, :journal_details

  def setup
    @journal = Journal.find 1
  end

  def test_journalized_is_an_issue
    issue = @journal.issue
    assert_kind_of Issue, issue
    assert_equal 1, issue.id
  end

  def test_new_status
    status = @journal.new_status
    assert_not_nil status
    assert_kind_of IssueStatus, status
    assert_equal 2, status.id 
  end
  
  def test_create_should_send_email_notification
    ActionMailer::Base.deliveries.clear
    issue = Issue.find(:first)
    user = User.find(:first)
    journal = issue.init_journal(user, issue)

    assert journal.save
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

end


# == Schema Information
#
# Table name: journals
#
#  id               :integer         not null, primary key
#  journalized_id   :integer         default(0), not null
#  journalized_type :string(30)      default(""), not null
#  user_id          :integer         default(0), not null
#  notes            :text
#  created_at       :datetime        not null
#  updated_at       :datetime
#

