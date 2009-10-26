# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class IssueObserver < ActiveRecord::Observer
  def after_create(issue)
    Mailer.deliver_issue_add(issue) if Setting.notified_events.include?('issue_added')
  end
end
