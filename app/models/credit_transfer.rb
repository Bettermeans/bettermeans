# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class CreditTransfer < ActiveRecord::Base
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => "User", :foreign_key => "recipient_id"
  belongs_to :project
  
  after_create :send_notification
  
  def send_notification
    Notification.create :recipient_id => self.recipient_id,
                        :variation => 'credits_transferred',
                        :params => {:amount => self.amount, :note => self.note, :project => self.project, :sender_name => sender.name}, 
                        :sender_id => self.sender_id,
                        :source_id => self.id,     
                        :source_type => "CreditTransfer"
    
  end
end