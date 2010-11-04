# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class WelcomeController < ApplicationController
  caches_action :robots
  ssl_required :all  
  
  before_filter :require_login, :except => :robots

  def index
    # @news = News.latest User.current
    # @projects = Project.latest User.current, 10, false
    # @enterprises = Project.latest User.current, 10, true
    # @activities_by_item = ActivityStream.fetch(nil, nil, true, 50)    
    @my_projects = User.current.owned_projects
    @belong_to_projects = User.current.belongs_to_projects
  end
  
  def robots
    @projects = Project.all_public.active
    render :layout => false, :content_type => 'text/plain'
  end
end
