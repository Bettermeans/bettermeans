# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class NewsObserver < ActiveRecord::Observer
  def after_create(news)
    Mailer.send_later(:deliver_news_added,news) if Setting.notified_events.include?('news_added')
  end
end
