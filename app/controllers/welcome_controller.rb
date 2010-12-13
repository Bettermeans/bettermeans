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
    
    @news = News.find(:all,
                             :limit => 10,
                             :order => "#{News.table_name}.created_at DESC",
                             :conditions => "#{News.table_name}.project_id in (#{User.current.projects.collect{|m| m.id}.join(',')}) AND (created_at > '#{Time.now.advance :days => (Setting::DAYS_FOR_LATEST_NEWS * -1)}')",
                             :include => [:project, :author]) unless User.current.projects.empty?
    
    @assigned_issues = Issue.visible.open.find(:all, 
                                    :conditions => {:assigned_to_id => User.current.id},
                                    # :limit => 10, 
                                    :include => [ :status, :project, :tracker ], 
                                    :order => "#{Issue.table_name}.updated_at DESC")
  end
  
  def robots
    @projects = Project.all_public.active
    render :layout => false, :content_type => 'text/plain'
  end
end
