# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

module QueriesHelper
  
  def operators_for_select(filter_type)
    Query.operators_by_filter_type[filter_type].collect {|o| [l(Query.operators[o]), o]}
  end
  
  def column_header(column)
    column.sortable ? sort_header_tag(column.name.to_s, :caption => column.caption,
                                                        :default_order => column.default_order) : 
                      content_tag('th', column.caption)
  end
  
  def column_content(column, issue)
    if column.is_a?(QueryCustomFieldColumn)
      cv = issue.custom_values.detect {|v| v.custom_field_id == column.custom_field.id}
      show_value(cv)
    else
      value = issue.send(column.name)
      if value.is_a?(Date)
        format_date(value)
      elsif value.is_a?(Time)
        format_time(value)
      else
        case column.name
        when :subject
        h((!@project.nil? && @project != issue.project) ? "#{issue.project.name} - " : '') +
          link_to(h(value), :controller => 'issues', :action => 'show', :id => issue)
        when :project
          link_to(h(value), :controller => 'projects', :action => 'show', :id => value)
        when :assigned_to
          link_to(h(value), :controller => 'account', :action => 'show', :id => value)
        when :author
          link_to(h(value), :controller => 'account', :action => 'show', :id => value)
        when :done_ratio
          progress_bar(value, :width => '80px')
        when :fixed_version
          link_to(h(value), { :controller => 'versions', :action => 'show', :id => issue.fixed_version_id })
        else
          h(value)
        end
      end
    end
  end
end
