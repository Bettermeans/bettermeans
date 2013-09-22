# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class IssueObserver < ActiveRecord::Observer
  def after_create(issue) # spec_me cover_me heckle_me
    Mailer.send_later(:deliver_issue_add,issue) if Setting.notified_events.include?('issue_added')
  end
end
