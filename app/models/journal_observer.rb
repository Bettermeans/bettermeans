# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class JournalObserver < ActiveRecord::Observer
  def after_create(journal) # spec_me cover_me heckle_me
    if journal.user == User.sysadmin #send system events to a daily digest
      all_recipients = journal.issue.recipients + (journal.issue.watcher_recipients - journal.issue.recipients)
      all_recipients.each do |rec|
        DailyDigest.create :mail => rec, :journal_id => journal.id, :issue_id => journal.issue.id
      end
    else
      Mailer.send_later(:deliver_issue_edit,journal) if Setting.notified_events.include?('issue_updated')
    end
  end
end
