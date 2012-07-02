# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class Track < ActiveRecord::Base
  belongs_to :user

  LOGIN = 1

  reportable :daily_logins, :aggregation => :count, :limit => 14, :conditions => ["code = ?", LOGIN]
  reportable :weekly_logins, :aggregation => :count, :grouping => :week, :limit => 20, :conditions => ["code = ?", LOGIN]

  def self.log(code, ip="")
    Track.send_later(:create, {:user_id => User.current.id, :code => code, :ip => ip})
  end
end
