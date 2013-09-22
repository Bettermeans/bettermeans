# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class DocumentObserver < ActiveRecord::Observer
  def after_create(document) # spec_me cover_me heckle_me
    Mailer.send_later(:deliver_document_added,document) if Setting.notified_events.include?('document_added')
  end
end
