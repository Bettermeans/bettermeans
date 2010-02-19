# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class ProjectsController < ApplicationController
  menu_item :overview
  menu_item :activity, :only => :activity
  menu_item :roadmap, :only => :roadmap
  menu_item :dashboard, :only => :dashboard
  menu_item :files, :only => [:list_files, :add_file]
  menu_item :settings, :only => :settings
  menu_item :issues, :only => [:changelog]
  menu_item :team, :only => :team
  
  before_filter :find_project, :except => [ :index, :list, :add, :copy, :activity, :update_scale ]
  before_filter :find_optional_project, :only => :activity
  before_filter :authorize, :except => [ :index, :list, :add, :copy, :archive, :unarchive, :destroy, :activity, :join_core_team, :leave_core_team, :core_vote, :dashboard, :dashdata, :new_dashdata, :mypris, :update_scale ]
  before_filter :authorize_global, :only => :add
  before_filter :require_admin, :only => [ :copy, :archive, :unarchive, :destroy ]
  accept_key_auth :activity
  
  after_filter :only => [:add, :edit, :archive, :unarchive, :destroy] do |controller|
    if controller.request.post?
      controller.send :expire_action, :controller => 'welcome', :action => 'robots.txt'
    end
  end
  
  helper :sort
  include SortHelper
  helper :custom_fields
  include CustomFieldsHelper   
  helper :issues
  helper IssuesHelper
  helper :queries
  include QueriesHelper
  helper :repositories
  include RepositoriesHelper
  include ProjectsHelper
  
  # Lists visible projects
  def index
    respond_to do |format|
      format.html { 
        @projects = Project.visible.find(:all, :order => 'lft') 
      }
      format.atom {
        projects = Project.visible.find(:all, :order => 'created_on DESC',
                                              :limit => Setting.feeds_limit.to_i)
        render_feed(projects, :title => "#{Setting.app_title}: #{l(:label_project_latest)}")
      }
    end
  end
  
  # Add a new project
  def add
    logger.info(params.inspect)
    @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    @project = Project.new(params[:project])
    @parent = Project.find(params[:parent_id]) unless params[:parent_id].nil?
    logger.info("PARENT BEFORE #{@parent.inspect}")
    
    if request.get?
      @project.enabled_module_names = Setting.default_projects_modules
    else
      logger.info("PROJECT BEFORE SAVE #{@project.inspect}")
      @project.enabled_module_names = params[:enabled_modules]
      @project.enterprise_id = @parent.enterprise_id unless @parent.nil?
      @project.identifier = Project.next_identifier # if Setting.sequential_project_identifiers?
      logger.info("Project is #{@project.identifier}")
      @project.trackers = Tracker.all
      @project.is_public = Setting.default_projects_public?
      @project.homepage = url_for(:controller => 'projects', :action => 'wiki', :id => @project)
      logger.info("INSPECTING PROJECT #{@project}")
      if validate_parent_id && @project.save
        logger.info("PARENT #{@parent.inspect}")
        @project.set_allowed_parent!(@parent.id) unless @parent.nil?
        # Add current user as a admin and core team member
        r = Role.find(Role::BUILTIN_CORE_MEMBER)
        r2 = Role.find(Role::BUILTIN_ADMINISTRATOR)
        m = Member.new(:user => User.current, :roles => [r,r2])
        @project.members << m
        flash[:notice] = l(:notice_successful_create)
        redirect_to :controller => 'projects', :action => 'show', :id => @project
      end
    end	
  end
  
  def copy
    @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    @trackers = Tracker.all
    @root_projects = Project.find(:all,
                                  :conditions => "parent_id IS NULL AND status = #{Project::STATUS_ACTIVE}",
                                  :order => 'name')
    @source_project = Project.find(params[:id])
    if request.get?
      @project = Project.copy_from(@source_project)
      if @project
        @project.identifier = Project.next_identifier if Setting.sequential_project_identifiers?
      else
        redirect_to :controller => 'admin', :action => 'projects'
      end  
    else
      @project = Project.new(params[:project])
      @project.enabled_module_names = params[:enabled_modules]
      if validate_parent_id && @project.copy(@source_project, :only => params[:only])
        @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
        flash[:notice] = l(:notice_successful_create)
        redirect_to :controller => 'admin', :action => 'projects'
      end		
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to :controller => 'admin', :action => 'projects'
  end
	
  # Show @project
  def show
    if params[:jump]
      # try to redirect to the requested menu item
      redirect_to_project_menu_item(@project, params[:jump]) && return
    end
    
    @users_by_role = @project.users_by_role
    @subprojects = @project.children.visible
    @news = @project.news.find(:all, :limit => 5, :include => [ :author, :project ], :order => "#{News.table_name}.created_on DESC")
    @trackers = @project.rolled_up_trackers
    
    cond = @project.project_condition(Setting.display_subprojects_issues?)
    
    @open_issues_by_tracker = Issue.visible.count(:group => :tracker,
                                            :include => [:project, :status, :tracker],
                                            :conditions => ["(#{cond}) AND #{IssueStatus.table_name}.is_closed=?", false])
    @total_issues_by_tracker = Issue.visible.count(:group => :tracker,
                                            :include => [:project, :status, :tracker],
                                            :conditions => cond)
    
    TimeEntry.visible_by(User.current) do
      @total_hours = TimeEntry.sum(:hours, 
                                   :include => :project,
                                   :conditions => cond).to_f
    end
    @key = User.current.rss_key
  end
  
  #Current user decides to join core team
  def join_core_team
    User.current.add_to_core(@project)
    
    respond_to do |format|
      format.js  { render :action => "team_update"}        
      format.html { redirect_to :action => 'team', :id => @project }
      format.xml  { head :ok }
    end
    
  end

  def leave_core_team
    TeamPoint.delete_all :project_id => @project.id, :recipient_id => User.current.id, :author_id => User.current.id
    User.current.drop_from_core(@project)
    
    respond_to do |format|
      format.js  { render :action => "team_update"}        
      format.html { redirect_to :action => 'team', :id => @project }
      format.xml  { head :ok }
    end
  end
  
  def dashboard
    @show_issue_id = params[:show_issue_id] #Optional parameter to start the dashboard off showing an issue
    @show_retro_id = params[:show_retro_id] #Optional parameter to start the dashboard off showing a retrospective
  end
  
  #TODO: optimize this query, it's WAY too heavy, and we need fewer columns, and it's executing hundreds of queries!
  def dashdata
    #TODO: could optimize by hardcoding archived issue status id to 12
    # render :json => Issue.find(:all, :conditions => "project_id = #{@project.id} AND (status_id <> #{IssueStatus.archived.id})").to_json(:include => {:journals => {:include => :user}, :issue_votes => {:include => :user}, :status => {:only => :name}, :todos => {:only => [:id, :subject, :completed_on]}, :tracker => {:only => [:name,:id]}, :author => {:only => [:firstname, :lastname, :login]}, :assigned_to => {:only => [:firstname, :lastname, :login]}})
    render :json => Issue.find(:all, :conditions => "project_id = #{@project.id}").to_json(:include => {:journals => {:include => :user}, :issue_votes => {:include => :user}, :status => {:only => :name}, :todos => {:only => [:id, :subject, :completed_on]}, :tracker => {:only => [:name,:id]}, :author => {:only => [:firstname, :lastname, :login]}, :assigned_to => {:only => [:firstname, :lastname, :login]}})
  end
  
  #Checks to see if any items have changed in this project (in the last params[:seconds]). If it has, returns only items that have changed
  def new_dashdata
    if @project.last_item_updated_on.nil?
      @project.last_item_updated_on = DateTime.now
      @project.save
    end
    time_delta = params[:seconds].to_f.round
    if @project.last_item_updated_on.advance(:seconds => time_delta) > DateTime.now
        logger.info("fresh data!")
        logger.info("last updated: #{@project.last_item_updated_on}")
        logger.info("date now: #{DateTime.now}")
        render :json => Issue.find(:all, :conditions => "project_id = #{@project.id} AND updated_on >= '#{@project.last_item_updated_on.advance(:seconds => -1 * time_delta)}'").to_json(:include => {:journals => {:include => :user}, :issue_votes => {:include => :user}, :status => {:only => :name}, :todos => {:only => [:id, :subject, :completed_on]}, :tracker => {:only => [:name,:id]}, :author => {:only => [:firstname, :lastname, :login]}, :assigned_to => {:only => [:firstname, :lastname, :login]}})
    else
        logger.info("no data")
        render :text => 'no'
    end
  end
  
  def update_scale
    render :update do |page|
      page.replace 'point_scale', :partial => 'point_scale', :locals => { :dpp => params[:dpp] }
      page["point_scale"].visual_effect :highlight
    end
  end

  #TODO: remove this function, we're no longer using it??
  #Returns my priorities for issues belonging to this project
  def mypris
    render :json => Issue.find(:all, :conditions => "project_id = #{@project.id} AND id IN (SELECT DISTINCT issue_id FROM #{Pri.table_name} where user_id = #{User.current.id})", :select => "id").to_json
  end
  
  #Current user voting someone else up or down
  def core_vote
    @value = params[:value]
    @member = Member.find(params[:member_id])

    TeamPoint.create :project => @project, :author => User.current, :recipient => @member.user, :value => @value
    
    respond_to do |format|
      format.js  { render :action => "core_vote"}        
    end
  end

  def settings
    @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    # @issue_category ||= IssueCategory.new
    @member ||= @project.members.new
    @trackers = Tracker.all
    @repository ||= @project.repository
    @wiki ||= @project.wiki
  end
  
  # Edit @project
  def edit
    if request.post?
      @project.attributes = params[:project]
      if validate_parent_id && @project.save
        logger.info("project SAVED")
        @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'settings', :id => @project
      else
        settings
        logger.info("project not saved")
        render :action => 'settings'
      end
    end
  end
  
  def modules
    @project.enabled_module_names = params[:enabled_modules]
    redirect_to :action => 'settings', :id => @project, :tab => 'modules'
  end

  def archive
    if request.post?
      unless @project.archive
        flash[:error] = l(:error_can_not_archive_project)
      end
    end
    redirect_to(url_for(:controller => 'admin', :action => 'projects', :status => params[:status]))
  end
  
  def unarchive
    @project.unarchive if request.post? && !@project.active?
    redirect_to(url_for(:controller => 'admin', :action => 'projects', :status => params[:status]))
  end
  
  # Delete @project
  def destroy
    @project_to_destroy = @project
    if request.post? and params[:confirm]
      @project_to_destroy.destroy
      redirect_to :controller => 'admin', :action => 'projects'
    end
    # hide project in layout
    @project = nil
  end
	
  # Add a new issue category to @project
  # def add_issue_category
  #   @category = @project.issue_categories.build(params[:category])
  #   if request.post?
  #     if @category.save
  #       respond_to do |format|
  #         format.html do
  #           flash[:notice] = l(:notice_successful_create)
  #           redirect_to :action => 'settings', :tab => 'categories', :id => @project
  #         end
  #         format.js do
  #           # IE doesn't support the replace_html rjs method for select box options
  #           render(:update) {|page| page.replace "issue_category_id",
  #             content_tag('select', '<option></option>' + options_from_collection_for_select(@project.issue_categories, 'id', 'name', @category.id), :id => 'issue_category_id', :name => 'issue[category_id]')
  #           }
  #         end
  #       end
  #     else
  #       respond_to do |format|
  #         format.html
  #         format.js do
  #           render(:update) {|page| page.alert(@category.errors.full_messages.join('\n')) }
  #         end
  #       end
  #     end
  #   end
  # end
	
  # Add a new version to @project
  def add_version
    @version = @project.versions.build
    if params[:version]
      attributes = params[:version].dup
      attributes.delete('sharing') unless attributes.nil? || @version.allowed_sharings.include?(attributes['sharing'])
      @version.attributes = attributes
    end
  	if request.post?
  	  if @version.save
        respond_to do |format|
          format.html do
            flash[:notice] = l(:notice_successful_create)
            redirect_to :action => 'settings', :tab => 'versions', :id => @project
          end
          format.js do
            # IE doesn't support the replace_html rjs method for select box options
            render(:update) {|page| page.replace "issue_fixed_version_id",
              content_tag('select', '<option></option>' + version_options_for_select(@project.shared_versions.open, @version), :id => 'issue_fixed_version_id', :name => 'issue[fixed_version_id]')
            }
          end
        end
      else
        respond_to do |format|
          format.html
          format.js do
            render(:update) {|page| page.alert(@version.errors.full_messages.join('\n')) }
          end
        end
  	  end
  	end
  end

  def add_file
    if request.post?
      container = (params[:version_id].blank? ? @project : @project.versions.find_by_id(params[:version_id]))
      attachments = attach_files(container, params[:attachments])
      if !attachments.empty? && Setting.notified_events.include?('file_added')
        Mailer.deliver_attachments_added(attachments)
      end
      redirect_to :controller => 'projects', :action => 'list_files', :id => @project
      return
    end
    @versions = @project.versions.sort
  end

  def save_activities
    if request.post? && params[:enumerations]
      Project.transaction do
        params[:enumerations].each do |id, activity|
          @project.update_or_create_time_entry_activity(id, activity)
        end
      end
    end
    
    redirect_to :controller => 'projects', :action => 'settings', :tab => 'activities', :id => @project
  end

  def reset_activities
    @project.time_entry_activities.each do |time_entry_activity|
      time_entry_activity.destroy(time_entry_activity.parent)
    end
    redirect_to :controller => 'projects', :action => 'settings', :tab => 'activities', :id => @project
  end
  
  def list_files
    sort_init 'filename', 'asc'
    sort_update 'filename' => "#{Attachment.table_name}.filename",
                'created_on' => "#{Attachment.table_name}.created_on",
                'size' => "#{Attachment.table_name}.filesize",
                'downloads' => "#{Attachment.table_name}.downloads"
                
    @containers = [ Project.find(@project.id, :include => :attachments, :order => sort_clause)]
    @containers += @project.versions.find(:all, :include => :attachments, :order => sort_clause).sort.reverse
    render :layout => !request.xhr?
  end

  def roadmap
    @trackers = @project.trackers.find(:all, :order => 'position')
    retrieve_selected_tracker_ids(@trackers, @trackers.select {|t| t.is_in_roadmap?})
    @with_subprojects = params[:with_subprojects].nil? ? Setting.display_subprojects_issues? : (params[:with_subprojects] == '1')
    project_ids = @with_subprojects ? @project.self_and_descendants.collect(&:id) : [@project.id]
    
    @versions = @project.shared_versions.sort
    @versions.reject! {|version| version.closed? || version.completed? } unless params[:completed]
    
    @issues_by_version = {}
    unless @selected_tracker_ids.empty?
      @versions.each do |version|
        conditions = {:tracker_id => @selected_tracker_ids}
        if !@project.versions.include?(version)
          conditions.merge!(:project_id => project_ids)
        end
        issues = version.fixed_issues.visible.find(:all,
                                                   :include => [:project, :status, :tracker, :priority],
                                                   :conditions => conditions,
                                                   :order => "#{Project.table_name}.lft, #{Tracker.table_name}.position, #{Issue.table_name}.id")
        @issues_by_version[version] = issues
      end
    end
    @versions.reject! {|version| !project_ids.include?(version.project_id) && @issues_by_version[version].empty?}
  end
  
  def team
      @days = Setting.activity_days_default.to_i    
  end
  
  
  def activity
    @days = Setting.activity_days_default.to_i
    
    if params[:from]
      begin; @date_to = params[:from].to_date + 1; rescue; end
    end

    @date_to ||= Date.today + 1
    @date_from = @date_to - @days
    @with_subprojects = params[:with_subprojects].nil? ? Setting.display_subprojects_issues? : (params[:with_subprojects] == '1')
    @author = (params[:user_id].blank? ? nil : User.active.find(params[:user_id]))
    
    @activity = Redmine::Activity::Fetcher.new(User.current, :project => @project, 
                                                             :with_subprojects => @with_subprojects,
                                                             :author => @author)
    @activity.scope_select {|t| !params["show_#{t}"].nil?}
    @activity.scope = (@author.nil? ? :default : :all) if @activity.scope.empty?

    events = @activity.events(@date_from, @date_to)
    
    if events.empty? || stale?(:etag => [events.first, User.current])
      respond_to do |format|
        format.html { 
          @events_by_day = events.group_by(&:event_date)
          render :layout => false if request.xhr?
        }
        format.atom {
          title = l(:label_activity)
          if @author
            title = @author.name
          elsif @activity.scope.size == 1
            title = l("label_#{@activity.scope.first.singularize}_plural")
          end
          render_feed(events, :title => "#{@project || Setting.app_title}: #{title}")
        }
      end
    end
    
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
private
  # Find project of id params[:id]
  # if not found, redirect to project list
  # Used as a before_filter
  def find_project
    if (params[:show_issue_id])
      @project = Issue.find(params[:show_issue_id]).project
    else
      @project = Project.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_optional_project
    return true unless params[:id]
    @project = Project.find(params[:id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def retrieve_selected_tracker_ids(selectable_trackers, default_trackers=nil)
    if ids = params[:tracker_ids]
      @selected_tracker_ids = (ids.is_a? Array) ? ids.collect { |id| id.to_i.to_s } : ids.split('/').collect { |id| id.to_i.to_s }
    else
      @selected_tracker_ids = (default_trackers || selectable_trackers).collect {|t| t.id.to_s }
    end
  end
  
  # Validates parent_id param according to user's permissions
  # TODO: move it to Project model in a validation that depends on User.current
  def validate_parent_id
    return true if User.current.admin?
    parent_id = params[:project] && params[:project][:parent_id]
    if parent_id || @project.new_record?
      parent = parent_id.blank? ? nil : Project.find_by_id(parent_id.to_i)
      unless @project.allowed_parents.include?(parent)
        @project.errors.add :parent_id, :invalid
        return false
      end
    end
    true
  end
end
