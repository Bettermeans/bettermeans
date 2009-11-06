# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

module TimelogHelper
  include ApplicationHelper
  
  def render_timelog_breadcrumb
    links = []
    links << link_to(l(:label_project_all), {:project_id => nil, :issue_id => nil})
    links << link_to(h(@project), {:project_id => @project, :issue_id => nil}) if @project
    links << link_to_issue(@issue) if @issue
    breadcrumb links
  end

  # Returns a collection of activities for a select field.  time_entry
  # is optional and will be used to check if the selected TimeEntryActivity
  # is active.
  def activity_collection_for_select_options(time_entry=nil, project=nil)
    project ||= @project
    if project.nil?
      activities = TimeEntryActivity.active
    else
      activities = project.activities
    end

    collection = []
    if time_entry && time_entry.activity && !time_entry.activity.active?
      collection << [ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ]
    else
      collection << [ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ] unless activities.detect(&:is_default)
    end
    activities.each { |a| collection << [a.name, a.id] }
    collection
  end
  
  def select_hours(data, criteria, value)
  	if value.to_s.empty?
  		data.select {|row| row[criteria].blank? }
    else 
    	data.select {|row| row[criteria] == value}
    end
  end
  
  def sum_hours(data)
    sum = 0
    data.each do |row|
      sum += row['hours'].to_f
    end
    sum
  end
  
  def options_for_period_select(value)
    options_for_select([[l(:label_all_time), 'all'],
                        [l(:label_today), 'today'],
                        [l(:label_yesterday), 'yesterday'],
                        [l(:label_this_week), 'current_week'],
                        [l(:label_last_week), 'last_week'],
                        [l(:label_last_n_days, 7), '7_days'],
                        [l(:label_this_month), 'current_month'],
                        [l(:label_last_month), 'last_month'],
                        [l(:label_last_n_days, 30), '30_days'],
                        [l(:label_this_year), 'current_year']],
                        value)
  end
  
  def entries_to_csv(entries)
    ic = Iconv.new(l(:general_csv_encoding), 'UTF-8')    
    decimal_separator = l(:general_csv_decimal_separator)
    custom_fields = TimeEntryCustomField.find(:all)
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      # csv header fields
      headers = [l(:field_spent_on),
                 l(:field_user),
                 l(:field_activity),
                 l(:field_project),
                 l(:field_issue),
                 l(:field_tracker),
                 l(:field_subject),
                 l(:field_hours),
                 l(:field_comments)
                 ]
      # Export custom fields
      headers += custom_fields.collect(&:name)
      
      csv << headers.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
      # csv lines
      entries.each do |entry|
        fields = [format_date(entry.spent_on),
                  entry.user,
                  entry.activity,
                  entry.project,
                  (entry.issue ? entry.issue.id : nil),
                  (entry.issue ? entry.issue.tracker : nil),
                  (entry.issue ? entry.issue.subject : nil),
                  entry.hours.to_s.gsub('.', decimal_separator),
                  entry.comments
                  ]
        fields += custom_fields.collect {|f| show_value(entry.custom_value_for(f)) }
                  
        csv << fields.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
      end
    end
    export
  end
  
  def format_criteria_value(criteria, value)
    value.blank? ? l(:label_none) : ((k = @available_criterias[criteria][:klass]) ? k.find_by_id(value.to_i) : format_value(value, @available_criterias[criteria][:format]))
  end
  
  def report_to_csv(criterias, periods, hours)
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      # Column headers
      headers = criterias.collect {|criteria| l(@available_criterias[criteria][:label]) }
      headers += periods
      headers << l(:label_total)
      csv << headers.collect {|c| to_utf8(c) }
      # Content
      report_criteria_to_csv(csv, criterias, periods, hours)
      # Total row
      row = [ l(:label_total) ] + [''] * (criterias.size - 1)
      total = 0
      periods.each do |period|
        sum = sum_hours(select_hours(hours, @columns, period.to_s))
        total += sum
        row << (sum > 0 ? "%.2f" % sum : '')
      end
      row << "%.2f" %total
      csv << row
    end
    export
  end
  
  def report_criteria_to_csv(csv, criterias, periods, hours, level=0)
    hours.collect {|h| h[criterias[level]].to_s}.uniq.each do |value|
      hours_for_value = select_hours(hours, criterias[level], value)
      next if hours_for_value.empty?
      row = [''] * level
      row << to_utf8(format_criteria_value(criterias[level], value))
      row += [''] * (criterias.length - level - 1)
      total = 0
      periods.each do |period|
        sum = sum_hours(select_hours(hours_for_value, @columns, period.to_s))
        total += sum
        row << (sum > 0 ? "%.2f" % sum : '')
      end
      row << "%.2f" %total
      csv << row
      
      if criterias.length > level + 1
        report_criteria_to_csv(csv, criterias, periods, hours_for_value, level + 1)
      end
    end
  end
  
  def to_utf8(s)
    @ic ||= Iconv.new(l(:general_csv_encoding), 'UTF-8')
    begin; @ic.iconv(s.to_s); rescue; s.to_s; end
  end
end
