# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class WelcomeController < ApplicationController
  caches_action :robots
  ssl_required :all

  before_filter :require_login, :except => :robots

  def index
    @my_projects = User.current.recent_projects(10)

    unless @my_projects.nil?
      @news = News.find(:all,
                               :limit => 30,
                               :order => "#{News.table_name}.created_at DESC",
                               :conditions => "#{News.table_name}.project_id in (#{User.current.projects.collect{|m| m.id}.join(',')}) AND (created_at > '#{Time.now.advance :days => (Setting::DAYS_FOR_LATEST_NEWS * -1)}')",
                               :include => [:project, :author]) unless User.current.projects.empty?

      @assigned_issues = Issue.visible.open.find(:all,
                                      :conditions => ["#{IssueVote.table_name}.user_id = ? AND #{IssueVote.table_name}.vote_type = ? AND #{Issue.table_name}.status_id = ?", User.current.id, IssueVote::JOIN_VOTE_TYPE, IssueStatus.assigned.id],
                                      :include => [:project, :tracker, :issue_votes ],
                                      :order => "#{Project.table_name}.name ASC")
    end
  end

  def robots
    @projects = Project.all_public.active
    render :layout => false, :content_type => 'text/plain'
  end
end
