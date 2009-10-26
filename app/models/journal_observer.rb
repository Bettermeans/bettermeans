# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class JournalObserver < ActiveRecord::Observer
  def after_create(journal)
    Mailer.deliver_issue_edit(journal) if Setting.notified_events.include?('issue_updated')
  end
end
