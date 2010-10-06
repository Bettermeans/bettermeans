# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class JournalObserver < ActiveRecord::Observer
  def after_create(journal)
    return if journal.user == User.sysadmin #Don't send system events for issue updates
    Mailer.send_later(:deliver_issue_edit,journal) if Setting.notified_events.include?('issue_updated')
  end
end
