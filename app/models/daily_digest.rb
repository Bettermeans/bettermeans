# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class DailyDigest < ActiveRecord::Base
  belongs_to :issue
  belongs_to :journal
  
  #TODO: change to send later
  #TODO: uncomment delete line
  
  def self.deliver
    digests_by_mail = DailyDigest.all.group_by{|digest| digest.mail}
    digests_by_mail.each_pair do |mail,journals| 
      Mailer.send(:deliver_daily_digest,mail,journals)
      # DailyDigest.delete_all :mail => mail
    end
  end
end
