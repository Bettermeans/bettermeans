# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

module WatchersHelper
  def watcher_tag(object, user)
    content_tag("span", watcher_link(object, user), :id => 'watcher')
  end
  
  def watcher_link(object, user)
    return '' unless user && user.logged? && object.respond_to?('watched_by?')
    watched = object.watched_by?(user)
    url = {:controller => 'watchers',
           :action => (watched ? 'unwatch' : 'watch'),
           :object_type => object.class.to_s.underscore,
           :object_id => object.id}           
    link_to_remote((watched ? l(:button_unwatch) : l(:button_watch)),
                   {:url => url},
                   :href => url_for(url),
                   :class => (watched ? 'icon icon-fav' : 'icon icon-fav-off'))
  
  end
  
  # Returns a comma separated list of users watching the given object
  def watchers_list(object)
    remove_allowed = User.current.allowed_to?("delete_#{object.class.name.underscore}_watchers".to_sym, object.project)
    object.watcher_users.collect do |user|
      s = content_tag('span', link_to_user(user), :class => 'user')
      if remove_allowed
        url = {:controller => 'watchers',
               :action => 'destroy',
               :object_type => object.class.to_s.underscore,
               :object_id => object.id,
               :user_id => user}
        s += ' ' + link_to_remote(image_tag('delete.png'),
                                  {:url => url},
                                  :href => url_for(url),
                                  :style => "vertical-align: middle")
      end
      s
    end.join(",\n")
  end
end
