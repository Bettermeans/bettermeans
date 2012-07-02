# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

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
    value = column.value(issue)

    case value.class.name
    when 'String'
      if column.name == :subject
        link_to(h(value), {:controller => 'issues', :action => 'show', :id => issue}, :class => "fancyframe")
      else
        h(value)
      end
    when 'Time'
      format_time(value)
    when 'Date'
      format_date(value)
    when 'Fixnum', 'Float'
      value.to_s
    when 'User'
      link_to_user value
    when 'Project'
      link_to(h(value), :controller => 'projects', :action => 'show', :id => value)
    when 'TrueClass'
      l(:general_text_Yes)
    when 'FalseClass'
      l(:general_text_No)
    else
      h(value)
    end
  end
end
