# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

module IssuesHelper
  include ApplicationHelper

  def render_issue_tooltip(issue)
    @cached_label_start_date ||= l(:field_start_date)
    @cached_label_due_date ||= l(:field_due_date)
    @cached_label_assigned_to ||= l(:field_assigned_to)
    
    link_to_issue(issue) + "<br /><br />" +
      "<strong>#{@cached_label_start_date}</strong>: #{format_date(issue.start_date)}<br />" +
      "<strong>#{@cached_label_due_date}</strong>: #{format_date(issue.due_date)}<br />" +
      "<strong>#{@cached_label_assigned_to}</strong>: #{issue.assigned_to}<br />"
  end
  
  def sidebar_queries
    unless @sidebar_queries
      # User can see public queries and his own queries
      visible = ARCondition.new(["is_public = ? OR user_id = ?", true, (User.current.logged? ? User.current.id : 0)])
      # Project specific queries and global queries
      visible << (@project.nil? ? ["project_id IS NULL"] : ["project_id IS NULL OR project_id = ?", @project.id])
      @sidebar_queries = Query.find(:all, 
                                    :select => 'id, name',
                                    :order => "name ASC",
                                    :conditions => visible.conditions)
    end
    @sidebar_queries
  end

  
  def issues_to_csv(issues, project = nil)
    ic = Iconv.new(l(:general_csv_encoding), 'UTF-8')    
    decimal_separator = l(:general_csv_decimal_separator)
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      # csv header fields
      headers = [ "#",
                  l(:field_status), 
                  l(:field_project),
                  l(:field_tracker),
                  l(:field_subject),
                  l(:field_assigned_to),
                  l(:field_author),
                  l(:field_start_date),
                  l(:field_due_date),
                  l(:field_estimated_hours),
                  l(:field_created_at),
                  l(:field_updated_at)
                  ]
      # Description in the last column
      headers << l(:field_description)
      csv << headers.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
      # csv lines
      issues.each do |issue|
        fields = [issue.id,
                  issue.status.name, 
                  issue.project.name,
                  issue.tracker.name, 
                  issue.subject,
                  issue.assigned_to,
                  issue.author.name,
                  format_date(issue.start_date),
                  format_date(issue.due_date),
                  issue.estimated_hours.to_s.gsub('.', decimal_separator),
                  format_time(issue.created_at),  
                  format_time(issue.updated_at)
                  ]
        fields << issue.description
        csv << fields.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
      end
    end
    export
  end
  
  def collection_for_project_members_select
    values = @issue.project.root.all_members.collect {|p| [p.name, p.user.id]}
    existing_team = @issue.team_votes.collect {|p| [User.find(p.user_id).name, p.user_id]}
    values - existing_team
  end
  
end
