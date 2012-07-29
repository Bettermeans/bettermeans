# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license
#

class QueryColumn
  attr_accessor :name, :sortable, :groupable, :default_order
  include Redmine::I18n

  def initialize(name, options={})
    self.name = name
    self.sortable = options[:sortable]
    self.groupable = options[:groupable] || false
    if groupable == true
      self.groupable = name.to_s
    end
    self.default_order = options[:default_order]
  end

  def caption
    l("field_#{name}")
  end

  # Returns true if the column is sortable, otherwise false
  def sortable?
    !sortable.nil?
  end

  def value(issue)
    issue.send name
  end
end

class Query < ActiveRecord::Base
  class StatementInvalid < ::ActiveRecord::StatementInvalid
  end

  belongs_to :project
  belongs_to :user
  serialize :filters
  serialize :column_names
  serialize :sort_criteria, Array

  attr_protected :project_id, :user_id

  validates_presence_of :name, :on => :save
  validates_length_of :name, :maximum => 255

  @@operators = { "="   => :label_equals,
                  "!"   => :label_not_equals,
                  "o"   => :label_open_issues,
                  "c"   => :label_closed_issues,
                  "!*"  => :label_none,
                  "*"   => :label_all,
                  ">="  => :label_greater_or_equal,
                  "<="  => :label_less_or_equal,
                  "<t+" => :label_in_less_than,
                  ">t+" => :label_in_more_than,
                  "t+"  => :label_in,
                  "t"   => :label_today,
                  "w"   => :label_this_week,
                  ">t-" => :label_less_than_ago,
                  "<t-" => :label_more_than_ago,
                  "t-"  => :label_ago,
                  "~"   => :label_contains,
                  "!~"  => :label_not_contains }

  cattr_reader :operators

  @@operators_by_filter_type = { :list => [ "=", "!" ],
                                 :list_status => [ "o", "=", "!", "c", "*" ],
                                 :list_optional => [ "=", "!", "!*", "*" ],
                                 :list_subprojects => [ "*", "!*", "=" ],
                                 :date => [ "<t+", ">t+", "t+", "t", "w", ">t-", "<t-", "t-" ],
                                 :date_past => [ ">t-", "<t-", "t-", "t", "w" ],
                                 :string => [ "=", "~", "!", "!~" ],
                                 :text => [  "~", "!~" ],
                                 :integer => [ "=", ">=", "<=", "!*", "*" ] }

  cattr_reader :operators_by_filter_type

  @@available_columns = [
    QueryColumn.new(:project, :sortable => "#{Project.table_name}.name", :groupable => true),
    QueryColumn.new(:tracker, :sortable => "#{Tracker.table_name}.position", :groupable => true),
    QueryColumn.new(:status, :sortable => "#{IssueStatus.table_name}.position", :groupable => true),
    QueryColumn.new(:pri, :sortable => "#{Issue.table_name}.pri", :default_order => 'desc', :groupable => true),
    QueryColumn.new(:subject, :sortable => "#{Issue.table_name}.subject"),
    QueryColumn.new(:author),
    QueryColumn.new(:assigned_to, :sortable => ["#{User.table_name}.lastname", "#{User.table_name}.firstname", "#{User.table_name}.id"], :groupable => true),
    QueryColumn.new(:updated_at, :sortable => "#{Issue.table_name}.updated_at", :default_order => 'desc'),
    QueryColumn.new(:start_date, :sortable => "#{Issue.table_name}.start_date"),
    QueryColumn.new(:due_date, :sortable => "#{Issue.table_name}.due_date"),
    QueryColumn.new(:estimated_hours, :sortable => "#{Issue.table_name}.estimated_hours"),
    QueryColumn.new(:created_at, :sortable => "#{Issue.table_name}.created_at", :default_order => 'desc'),
  ]
  cattr_reader :available_columns

  def initialize(attributes = nil)
    super attributes
    self.filters ||= { 'status_id' => {:operator => "o", :values => [""]} }
  end

  def after_initialize
    # Store the fact that project is nil (used in #editable_by?)
    @is_for_all = project.nil?
  end

  def validate
    filters.each_key do |field|
      errors.add label_for(field), :blank unless
          # filter requires one or more values
          (values_for(field) and !values_for(field).first.blank?) or
          # filter doesn't require any value
          ["o", "c", "!*", "*", "t", "w"].include? operator_for(field)
    end if filters
  end

  def editable_by?(user)
    return false unless user
    # Admin can edit them all and regular users can edit their private queries
    return true if user.admin? || (!is_public && self.user_id == user.id)
    # Members can not edit public queries that are for all project (only admin is allowed to)
    is_public && !@is_for_all && user.allowed_to?(:manage_public_queries, project)
  end

  def available_filters
    return @available_filters if @available_filters

    trackers = project.nil? ? Tracker.find(:all, :order => 'position') : project.rolled_up_trackers

    @available_filters = { "status_id" => { :type => :list_status, :order => 1, :values => IssueStatus.find(:all, :order => 'position').collect{|s| [s.name, s.id.to_s] } },
                           "tracker_id" => { :type => :list, :order => 2, :values => trackers.collect{|s| [s.name, s.id.to_s] } },
                           "subject" => { :type => :text, :order => 8 },
                           "created_at" => { :type => :date_past, :order => 9 },
                           "updated_at" => { :type => :date_past, :order => 10 },
                           "start_date" => { :type => :date, :order => 11 },
                           "due_date" => { :type => :date, :order => 12 },
                           "estimated_hours" => { :type => :integer, :order => 13 }
                         }

    user_values = []
    user_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
    if project
      user_values += project.users.sort.collect{|s| [s.name, s.id.to_s] }
    else
      # members of the user's projects
      # OPTIMIZE: Is selecting from users per project (N+1)
      user_values += User.current.projects.collect(&:users).flatten.uniq.sort.collect{|s| [s.name, s.id.to_s] }
    end
    @available_filters["assigned_to_id"] = { :type => :list_optional, :order => 4, :values => user_values } unless user_values.empty?
    @available_filters["author_id"] = { :type => :list, :order => 5, :values => user_values } unless user_values.empty?

    if User.current.logged?
      @available_filters["watcher_id"] = { :type => :list, :order => 15, :values => [["<< #{l(:label_me)} >>", "me"]] }
    end

    if project
      unless @project.descendants.active.empty?
        @available_filters["subproject_id"] = { :type => :list_subprojects, :order => 13, :values => @project.descendants.visible.collect{|s| [s.name, s.id.to_s] } }
      end
    else
      # global filters for cross project issue list
    end
    @available_filters
  end

  def add_filter(field, operator, values)
    # values must be an array
    return unless values and values.is_a? Array
    # check if field is defined as an available filter
    if available_filters.has_key? field
      filter_options = available_filters[field]
      filters[field] = {:operator => operator, :values => values }
    end
  end

  def add_short_filter(field, expression)
    return unless expression
    parms = expression.scan(/^(o|c|\!|\*)?(.*)$/).first
    add_filter field, (parms[0] || "="), [parms[1] || ""]
  end

  def has_filter?(field)
    filters and filters[field]
  end

  def operator_for(field)
    has_filter?(field) ? filters[field][:operator] : nil
  end

  def values_for(field)
    has_filter?(field) ? filters[field][:values] : nil
  end

  def label_for(field)
    label = available_filters[field][:name] if available_filters.has_key?(field)
    label ||= field.gsub(/\_id$/, "")
  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = Query.available_columns
  end

  # Returns an array of columns that can be used to group the results
  def groupable_columns
    available_columns.select {|c| c.groupable}
  end

  def columns
    if has_default_columns?
      available_columns.select do |c|
        # Adds the project column by default for cross-project lists
        Setting.issue_list_default_columns.include?(c.name.to_s) || (c.name == :project && project.nil?)
      end
    else
      # preserve the column_names order
      column_names.collect {|name| available_columns.find {|col| col.name == name}}.compact
    end
  end

  def column_names=(names)
    if names
      names = names.select {|n| n.is_a?(Symbol) || !n.blank? }
      names = names.collect {|n| n.is_a?(Symbol) ? n : n.to_sym }
      # Set column_names to nil if default columns
      if names.map(&:to_s) == Setting.issue_list_default_columns
        names = nil
      end
    end
    write_attribute(:column_names, names)
  end

  def has_column?(column)
    column_names && column_names.include?(column.name)
  end

  def has_default_columns?
    column_names.nil? || column_names.empty?
  end

  def sort_criteria=(arg)
    c = []
    if arg.is_a?(Hash)
      arg = arg.keys.sort.collect {|k| arg[k]}
    end
    c = arg.select {|k,o| !k.to_s.blank?}.slice(0,3).collect {|k,o| [k.to_s, o == 'desc' ? o : 'asc']}
    write_attribute(:sort_criteria, c)
  end

  def sort_criteria
    read_attribute(:sort_criteria) || []
  end

  def sort_criteria_key(arg)
    sort_criteria && sort_criteria[arg] && sort_criteria[arg].first
  end

  def sort_criteria_order(arg)
    sort_criteria && sort_criteria[arg] && sort_criteria[arg].last
  end

  # Returns the SQL sort order that should be prepended for grouping
  def group_by_sort_order
    if grouped? && (column = group_by_column)
      column.sortable.is_a?(Array) ?
        column.sortable.collect {|s| "#{s} #{column.default_order}"}.join(',') :
        "#{column.sortable} #{column.default_order}"
    end
  end

  # Returns true if the query is a grouped query
  def grouped?
    !group_by.blank?
  end

  def group_by_column
    groupable_columns.detect {|c| c.name.to_s == group_by}
  end

  def group_by_statement
    group_by_column.groupable
  end

  def project_statement
    project_clauses = []
    if project && !@project.descendants.active.empty?
      ids = [project.id]
      if has_filter?("subproject_id")
        case operator_for("subproject_id")
        when '='
          # include the selected subprojects
          ids += values_for("subproject_id").each(&:to_i)
        when '!*'
          # main project only
        else
          # all subprojects
          ids += project.descendants.collect(&:id)
        end
      elsif Setting.display_subprojects_issues?
        ids += project.descendants.collect(&:id)
      end
      project_clauses << "#{Project.table_name}.id IN (%s)" % ids.join(',')
    elsif project
      project_clauses << "#{Project.table_name}.id = %d" % project.id
    end
    project_clauses <<  Project.allowed_to_condition(User.current, :view_issues)
    project_clauses.join(' AND ')
  end

  def statement
    # filters clauses
    filters_clauses = []
    filters.each_key do |field|
      next if field == "subproject_id"
      v = values_for(field).clone
      next unless v and !v.empty?
      operator = operator_for(field)

      # "me" value subsitution
      if %w(assigned_to_id author_id watcher_id).include?(field)
        v.push(User.current.logged? ? User.current.id.to_s : "0") if v.delete("me")
      end

      sql = ''
      if field == 'watcher_id'
        db_table = Watcher.table_name
        db_field = 'user_id'
        sql << "#{Issue.table_name}.id #{ operator == '=' ? 'IN' : 'NOT IN' } (SELECT #{db_table}.watchable_id FROM #{db_table} WHERE #{db_table}.watchable_type='Issue' AND "
        sql << sql_for_field(field, '=', v, db_table, db_field) + ')'
      else
        # regular field
        db_table = Issue.table_name
        db_field = field
        sql << '(' + sql_for_field(field, operator, v, db_table, db_field) + ')'
      end
      filters_clauses << sql

    end if filters and valid?

    (filters_clauses << project_statement).join(' AND ')
  end

  # Returns the issue count
  def issue_count
    Issue.count(:include => [:status, :project], :conditions => statement)
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  # Returns the issue count by group or nil if query is not grouped
  def issue_count_by_group
    r = nil
    if grouped?
      begin
        # Rails will raise an (unexpected) RecordNotFound if there's only a nil group value
        r = Issue.count(:group => group_by_statement, :include => [:status, :project], :conditions => statement)
      rescue ActiveRecord::RecordNotFound
        r = {nil => issue_count}
      end
      c = group_by_column
    end
    r
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  # Returns the issues
  # Valid options are :order, :offset, :limit, :include, :conditions
  def issues(options={})
    order_option = [group_by_sort_order, options[:order]].reject {|s| s.blank?}.join(',')
    order_option = nil if order_option.blank?

    Issue.find :all, :include => ([:status, :project] + (options[:include] || [])).uniq,
                     :conditions => Query.merge_conditions(statement, options[:conditions]),
                     :order => order_option,
                     :limit  => options[:limit],
                     :offset => options[:offset]
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  # Returns the journals
  # Valid options are :order, :offset, :limit
  def journals(options={})
    Journal.find :all, :include => [:details, :user, {:issue => [:project, :author, :tracker, :status]}],
                       :conditions => statement,
                       :order => options[:order],
                       :limit => options[:limit],
                       :offset => options[:offset]
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  private

  # Helper method to generate the WHERE sql for a +field+, +operator+ and a +value+
  def sql_for_field(field, operator, value, db_table, db_field)
    sql = ''
    case operator
    when "="
      sql = "#{db_table}.#{db_field} IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
    when "!"
      sql = "(#{db_table}.#{db_field} IS NULL OR #{db_table}.#{db_field} NOT IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + "))"
    when "!*"
      sql = "#{db_table}.#{db_field} IS NULL"
    when "*"
      sql = "#{db_table}.#{db_field} IS NOT NULL"
    when ">="
      sql = "#{db_table}.#{db_field} >= #{value.first.to_i}"
    when "<="
      sql = "#{db_table}.#{db_field} <= #{value.first.to_i}"
    when "o"
      sql = "#{IssueStatus.table_name}.is_closed=#{connection.quoted_false}" if field == "status_id"
    when "c"
      sql = "#{IssueStatus.table_name}.is_closed=#{connection.quoted_true}" if field == "status_id"
    when ">t-"
      sql = date_range_clause(db_table, db_field, - value.first.to_i, 0)
    when "<t-"
      sql = date_range_clause(db_table, db_field, nil, - value.first.to_i)
    when "t-"
      sql = date_range_clause(db_table, db_field, - value.first.to_i, - value.first.to_i)
    when ">t+"
      sql = date_range_clause(db_table, db_field, value.first.to_i, nil)
    when "<t+"
      sql = date_range_clause(db_table, db_field, 0, value.first.to_i)
    when "t+"
      sql = date_range_clause(db_table, db_field, value.first.to_i, value.first.to_i)
    when "t"
      sql = date_range_clause(db_table, db_field, 0, 0)
    when "w"
      from = l(:general_first_day_of_week) == '7' ?
      # week starts on sunday
      ((Date.today.cwday == 7) ? Time.now.at_beginning_of_day : Time.now.at_beginning_of_week - 1.day) :
        # week starts on monday (Rails default)
        Time.now.at_beginning_of_week
      sql = "#{db_table}.#{db_field} BETWEEN '%s' AND '%s'" % [connection.quoted_date(from), connection.quoted_date(from + 7.days)]
    when "~"
      sql = "LOWER(#{db_table}.#{db_field}) LIKE '%#{connection.quote_string(value.first.to_s.downcase)}%'"
    when "!~"
      sql = "LOWER(#{db_table}.#{db_field}) NOT LIKE '%#{connection.quote_string(value.first.to_s.downcase)}%'"
    end

    return sql
  end

  # Returns a SQL clause for a date or datetime field.
  def date_range_clause(table, field, from, to)
    s = []
    if from
      s << ("#{table}.#{field} > '%s'" % [connection.quoted_date((Date.yesterday + from).to_time.end_of_day)])
    end
    if to
      s << ("#{table}.#{field} <= '%s'" % [connection.quoted_date((Date.today + to).to_time.end_of_day)])
    end
    s.join(' AND ')
  end

end


# == Schema Information
#
# Table name: queries
#
#  id            :integer         not null, primary key
#  project_id    :integer
#  name          :string(255)     default(""), not null
#  filters       :text
#  user_id       :integer         default(0), not null
#  is_public     :boolean         default(FALSE), not null
#  column_names  :text
#  sort_criteria :text
#  group_by      :string(255)
#

