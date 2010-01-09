# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class DocumentObserver < ActiveRecord::Observer
  def after_create(document)
    Mailer.send_later(:deliver_document_added,document) if Setting.notified_events.include?('document_added')
  end
end
