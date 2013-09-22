# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

class WikiContentObserver < ActiveRecord::Observer
  def after_create(wiki_content) # spec_me cover_me heckle_me
    Mailer.deliver_wiki_content_added(wiki_content) if Setting.notified_events.include?('wiki_content_added')
  end

  def after_update(wiki_content) # spec_me cover_me heckle_me
    if wiki_content.text_changed?
      Mailer.deliver_wiki_content_updated(wiki_content) if Setting.notified_events.include?('wiki_content_updated')
    end
  end
end
