# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class MessageObserver < ActiveRecord::Observer
  def after_create(message)
    recipients = []
    # send notification to the topic watchers
    recipients += message.root.watcher_recipients
    # send notification to the board watchers
    recipients += message.board.watcher_recipients
    # send notification to project members who want to be notified
    recipients += message.board.project.recipients
    recipients = recipients.compact.uniq
    Mailer.deliver_message_posted(message, recipients) if !recipients.empty? && Setting.notified_events.include?('message_posted')
  end
end
