# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class ReportsController < ApplicationController
  menu_item :issues
  before_filter :find_project, :authorize

  def issue_report
    @statuses = IssueStatus.find(:all, :order => 'position')
    
    case params[:detail]
    when "tracker"
      @field = "tracker_id"
      @rows = @project.trackers
      @data = issues_by_tracker
      @report_title = l(:field_tracker)
      render :template => "reports/issue_report_details"
    when "assigned_to"
      @field = "assigned_to_id"
      @rows = @project.all_members.collect { |m| m.user }
      @data = issues_by_assigned_to
      @report_title = l(:field_assigned_to)
      render :template => "reports/issue_report_details"
    when "author"
      @field = "author_id"
      @rows = @project.all_members.collect { |m| m.user }
      @data = issues_by_author
      @report_title = l(:field_author)
      render :template => "reports/issue_report_details"  
    when "subproject"
      @field = "project_id"
      @rows = @project.descendants.active
      @data = issues_by_subproject
      @report_title = l(:field_subproject)
      render :template => "reports/issue_report_details"  
    else
      @trackers = @project.trackers
      @categories = @project.issue_categories
      @assignees = @project.all_members.collect { |m| m.user }
      @authors = @project.all_members.collect { |m| m.user }
      @subprojects = @project.descendants.active
      issues_by_tracker
      issues_by_assigned_to
      issues_by_author
      issues_by_subproject
      
      render :template => "reports/issue_report"
    end
  end  
  
private
  # Find project of id params[:id]
  def find_project
    @project = Project.find(params[:id])		
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def issues_by_tracker
    @issues_by_tracker ||= 
        ActiveRecord::Base.connection.select_all("select    s.id as status_id, 
                                                  s.is_closed as closed, 
                                                  t.id as tracker_id,
                                                  count(i.id) as total 
                                                from 
                                                  #{Issue.table_name} i, #{IssueStatus.table_name} s, #{Tracker.table_name} t
                                                where 
                                                  i.status_id=s.id 
                                                  and i.tracker_id=t.id
                                                  and i.project_id=#{@project.id}
                                                group by s.id, s.is_closed, t.id")	
  end
  		
  def issues_by_assigned_to
    @issues_by_assigned_to ||= 
      ActiveRecord::Base.connection.select_all("select    s.id as status_id, 
                                                  s.is_closed as closed, 
                                                  a.id as assigned_to_id,
                                                  count(i.id) as total 
                                                from 
                                                  #{Issue.table_name} i, #{IssueStatus.table_name} s, #{User.table_name} a
                                                where 
                                                  i.status_id=s.id 
                                                  and i.assigned_to_id=a.id
                                                  and i.project_id=#{@project.id}
                                                group by s.id, s.is_closed, a.id")
  end
  
  def issues_by_author
    @issues_by_author ||= 
      ActiveRecord::Base.connection.select_all("select    s.id as status_id, 
                                                  s.is_closed as closed, 
                                                  a.id as author_id,
                                                  count(i.id) as total 
                                                from 
                                                  #{Issue.table_name} i, #{IssueStatus.table_name} s, #{User.table_name} a
                                                where 
                                                  i.status_id=s.id 
                                                  and i.author_id=a.id
                                                  and i.project_id=#{@project.id}
                                                group by s.id, s.is_closed, a.id")	
  end
  
  def issues_by_subproject
    @issues_by_subproject ||= 
      ActiveRecord::Base.connection.select_all("select    s.id as status_id, 
                                                  s.is_closed as closed, 
                                                  i.project_id as project_id,
                                                  count(i.id) as total 
                                                from 
                                                  #{Issue.table_name} i, #{IssueStatus.table_name} s
                                                where 
                                                  i.status_id=s.id 
                                                  and i.project_id IN (#{@project.descendants.active.collect{|p| p.id}.join(',')})
                                                group by s.id, s.is_closed, i.project_id") if @project.descendants.active.any?
    @issues_by_subproject ||= []
  end
end
