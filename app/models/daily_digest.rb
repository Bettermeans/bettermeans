# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class DailyDigest < ActiveRecord::Base
  belongs_to :issue
  belongs_to :journal

  def self.deliver # spec_me cover_me heckle_me
    digests_by_mail = DailyDigest.all.group_by{|digest| digest.mail}
    digests_by_mail.each_pair do |mail,journals|
      Mailer.send_later(:deliver_daily_digest,mail,journals)
      DailyDigest.delete_all :mail => mail
    end
  end
end
