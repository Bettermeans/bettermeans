# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

module IssuesHelper
  include ApplicationHelper

  def render_issue_tooltip(issue)
    @cached_label_start_date ||= l(:field_start_date)
    @cached_label_due_date ||= l(:field_due_date)
    @cached_label_assigned_to ||= l(:field_assigned_to)
    @cached_label_priority ||= l(:field_priority)
    
    link_to_issue(issue) + "<br /><br />" +
      "<strong>#{@cached_label_start_date}</strong>: #{format_date(issue.start_date)}<br />" +
      "<strong>#{@cached_label_due_date}</strong>: #{format_date(issue.due_date)}<br />" +
      "<strong>#{@cached_label_assigned_to}</strong>: #{issue.assigned_to}<br />" +
      "<strong>#{@cached_label_priority}</strong>: #{issue.priority.name}"
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
  


  def show_detail(detail, no_html=false)
    case detail.property
    when 'attr'
      label = l(("field_" + detail.prop_key.to_s.gsub(/\_id$/, "")).to_sym)   
      case detail.prop_key
      when 'due_date', 'start_date'
        value = format_date(detail.value.to_date) if detail.value
        old_value = format_date(detail.old_value.to_date) if detail.old_value
      when 'project_id'
        p = Project.find_by_id(detail.value) and value = p.name if detail.value
        p = Project.find_by_id(detail.old_value) and old_value = p.name if detail.old_value
      when 'status_id'
        s = IssueStatus.find_by_id(detail.value) and value = s.name if detail.value
        s = IssueStatus.find_by_id(detail.old_value) and old_value = s.name if detail.old_value
      when 'tracker_id'
        t = Tracker.find_by_id(detail.value) and value = t.name if detail.value
        t = Tracker.find_by_id(detail.old_value) and old_value = t.name if detail.old_value
      when 'assigned_to_id'
        u = User.find_by_id(detail.value) and value = u.name if detail.value
        u = User.find_by_id(detail.old_value) and old_value = u.name if detail.old_value
      when 'priority_id'
        e = IssuePriority.find_by_id(detail.value) and value = e.name if detail.value
        e = IssuePriority.find_by_id(detail.old_value) and old_value = e.name if detail.old_value
      when 'estimated_hours'
        value = "%0.02f" % detail.value.to_f unless detail.value.blank?
        old_value = "%0.02f" % detail.old_value.to_f unless detail.old_value.blank?
      end
    when 'attachment'
      label = l(:label_attachment)
    end

    label ||= detail.prop_key
    value ||= detail.value
    old_value ||= detail.old_value
    
    unless no_html
      label = content_tag('strong', label)
      old_value = content_tag("i", h(old_value)) if detail.old_value
      old_value = content_tag("strike", old_value) if detail.old_value and (!detail.value or detail.value.empty?)
      if detail.property == 'attachment' && !value.blank? && a = Attachment.find_by_id(detail.prop_key)
        # Link to the attachment if it has not been removed
        value = link_to_attachment(a)
      else
        value = content_tag("i", h(value)) if value
      end
    end
    
    if !detail.value.blank?
      case detail.property
      when 'attr', 'cf'
        if !detail.old_value.blank?
          l(:text_journal_changed, :label => label, :old => old_value, :new => value)
        else
          l(:text_journal_set_to, :label => label, :value => value)
        end
      when 'attachment'
        l(:text_journal_added, :label => label, :value => value)
      end
    else
      l(:text_journal_deleted, :label => label, :old => old_value)
    end
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
                  l(:field_priority),
                  l(:field_subject),
                  l(:field_assigned_to),
                  l(:field_author),
                  l(:field_start_date),
                  l(:field_due_date),
                  l(:field_estimated_hours),
                  l(:field_created_on),
                  l(:field_updated_on)
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
                  issue.priority.name,
                  issue.subject,
                  issue.assigned_to,
                  issue.author.name,
                  format_date(issue.start_date),
                  format_date(issue.due_date),
                  issue.estimated_hours.to_s.gsub('.', decimal_separator),
                  format_time(issue.created_on),  
                  format_time(issue.updated_on)
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
