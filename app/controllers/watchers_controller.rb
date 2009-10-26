# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class WatchersController < ApplicationController
  before_filter :find_project
  before_filter :require_login, :check_project_privacy, :only => [:watch, :unwatch]
  before_filter :authorize, :only => [:new, :destroy]
  
  verify :method => :post,
         :only => [ :watch, :unwatch ],
         :render => { :nothing => true, :status => :method_not_allowed }
  
  def watch
    set_watcher(User.current, true)
  end
  
  def unwatch
    set_watcher(User.current, false)
  end
  
  def new
    @watcher = Watcher.new(params[:watcher])
    @watcher.watchable = @watched
    @watcher.save if request.post?
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render :update do |page|
          page.replace_html 'watchers', :partial => 'watchers/watchers', :locals => {:watched => @watched}
        end
      end
    end
  rescue ::ActionController::RedirectBackError
    render :text => 'Watcher added.', :layout => true
  end
  
  def destroy
    @watched.set_watcher(User.find(params[:user_id]), false) if request.post?
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render :update do |page|
          page.replace_html 'watchers', :partial => 'watchers/watchers', :locals => {:watched => @watched}
        end
      end
    end
  end
  
private
  def find_project
    klass = Object.const_get(params[:object_type].camelcase)
    return false unless klass.respond_to?('watched_by')
    @watched = klass.find(params[:object_id])
    @project = @watched.project
  rescue
    render_404
  end
  
  def set_watcher(user, watching)
    @watched.set_watcher(user, watching)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render(:update) {|page| page.replace_html 'watcher', watcher_link(@watched, user)} }
    end
  rescue ::ActionController::RedirectBackError
    render :text => (watching ? 'Watcher added.' : 'Watcher removed.'), :layout => true
  end
end
