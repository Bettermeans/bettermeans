# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class WatchersController < ApplicationController
  before_filter :find_project
  before_filter :require_login, :check_project_privacy, :only => [:watch, :unwatch]
  before_filter :authorize, :only => [:new, :destroy]
  ssl_required :all

  verify :method => :post,
         :only => [ :watch, :unwatch ],
         :render => { :nothing => true, :status => :method_not_allowed }

  def watch
    if @watched.respond_to?(:visible?) && !@watched.visible?(User.current)
      render_403
    else
      set_watcher(User.current, true)
    end
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
    if params[:replace].present?
      if params[:replace].is_a? Array
        replace_ids = params[:replace]
      else
        replace_ids = [params[:replace]]
      end
    else
      replace_ids = 'watcher'
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render(:update) do |page|
          replace_ids.each do |replace_id|
            page.replace_html replace_id, watcher_link(@watched, user, :replace => replace_ids)
          end
        end
      end
    end
  rescue ::ActionController::RedirectBackError
    render :text => (watching ? 'Watcher added.' : 'Watcher removed.'), :layout => true
  end
end
