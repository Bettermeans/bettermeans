# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class MessageObserver < ActiveRecord::Observer
  def after_create(message)
    Mailer.send_later(:deliver_message_posted,message) if Setting.notified_events.include?('message_posted')
  end
end
