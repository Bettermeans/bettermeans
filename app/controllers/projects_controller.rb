# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class ProjectsController < ApplicationController
  menu_item :overview
  menu_item :activity, :only => :activity
  menu_item :dashboard, :only => :dashboard
  menu_item :files, :only => [:list_files, :add_file]
  menu_item :settings, :only => :settings
  menu_item :issues, :only => [:changelog]
  menu_item :team, :only => :team
  menu_item :credits, :only => :credits
  menu_item :shares, :only => :shares
  
  before_filter :find_project, :except => [ :index, :list, :copy, :activity, :update_scale, :add ]
  before_filter :find_optional_project, :only => [:activity, :add]
  before_filter :authorize, :except => [ :index, :list, :add, :copy, :archive, :unarchive, :destroy, :activity, :join_core_team, :leave_core_team, :core_vote, :dashboard, :dashdata, :new_dashdata, :mypris, :update_scale, :community_members ]
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
  helper :issues
  helper IssuesHelper
  helper :queries
  include QueriesHelper
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
    @project = Project.new(params[:project])
    @parent = Project.find(params[:parent_id]) unless params[:parent_id] == "" || params[:parent_id].nil?
    
    if request.get?
      @project.enabled_module_names = Setting.default_projects_modules
      @project.dpp = 100
      
    else
      @project.enabled_module_names = params[:enabled_modules]
      @project.enterprise_id = @parent.enterprise_id unless @parent.nil?
      @project.identifier = Project.next_identifier # if Setting.sequential_project_identifiers?
      @project.trackers = Tracker.all
      @project.is_public = Setting.default_projects_public?
      @project.homepage = url_for(:controller => 'projects', :action => 'wiki', :id => @project)
      if validate_parent_id && @project.save
        @project.set_allowed_parent!(@parent.id) #unless @parent.nil?
        if @parent.nil?
          # Add current user as a admin and core team member
          r = Role.find(Role::BUILTIN_CORE_MEMBER)
          r2 = Role.find(Role::BUILTIN_ADMINISTRATOR)
          m = Member.new(:user => User.current, :roles => [r,r2])
          @project.all_members << m
        end
        flash[:notice] = l(:notice_successful_create)
        redirect_to :controller => 'projects', :action => 'show', :id => @project
      end
    end	
  end
  
  def copy
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
    
    # @subprojects = @project.children.visible.find(:all, :order => 'name ASC')
    @subprojects = @project.children.active.find(:all, :order => 'name ASC')
    @news = @project.news.find(:all, :limit => 5, :include => [ :author, :project ], :order => "#{News.table_name}.created_on DESC")
    @trackers = @project.rolled_up_trackers
    
    cond = @project.project_condition(Setting.display_subprojects_issues?)
    
    @open_issues_by_tracker = Issue.visible.count(:group => :tracker,
                                            :include => [:project, :status, :tracker],
                                            :conditions => ["(#{cond}) AND #{IssueStatus.table_name}.is_closed=?", false])
    @total_issues_by_tracker = Issue.visible.count(:group => :tracker,
                                            :include => [:project, :status, :tracker],
                                            :conditions => cond)
    
    @key = User.current.rss_key
    
    @motions = @project.motions.viewable_by(User.current.position_for(@project)).allactive
    
  end
  
  def community_members
    render :json => @project.root.all_members.to_json(:only => :user_id, :methods => :name).gsub("\"user_id\":","\"").gsub(",\"name\"", "\"").gsub("}","").gsub("{","").gsub("[","{").gsub("]","}")
  end
  
  def dashboard
    @kufta = "whatever"
    @credit_base = @project.dpp
    @show_issue_id = params[:show_issue_id] #Optional parameter to start the dashboard off showing an issue
    @show_retro_id = params[:show_retro_id] #Optional parameter to start the dashboard off showing a retrospective
  end
  
  #TODO: optimize this query, it's WAY too heavy, and we need fewer columns, and it's executing hundreds of queries!
  def dashdata
    
    #TODO: could optimize by hardcoding archived issue status id to 12    
    # render :json => Issue.find(:all, :conditions => "project_id = #{@project.id} AND (status_id <> #{IssueStatus.archived.id})")  \
    #                      .to_json(:include => { :journals =>    { :include => :user },
    #                                             :issue_votes => { :include => :user },
    #                                             :status =>      { :only => :name },
    #                                             :todos =>       { :only => [:id, :subject, :completed_on] },
    #                                             :tracker =>     { :only => [:name,:id] },
    #                                             :author =>      { :only => [:firstname, :lastname, :login] },
    #                                             :assigned_to => { :only => [:firstname, :lastname, :login] }})
    
    render :json => Issue.find(:all, :conditions => "project_id = #{@project.id} AND (retro_id < 0 OR retro_id is null)")  \
                         .to_json(:include => { :journals =>    { :include => :user },
                                                :issue_votes => { :include => :user },
                                                :status =>      { :only => :name },
                                                :todos =>       { :only => [:id, :subject, :completed_on, :owner_login] },
                                                :tracker =>     { :only => [:name,:id] },
                                                :author =>      { :only => [:firstname, :lastname, :login, :mail] },
                                                :assigned_to => { :only => [:firstname, :lastname, :login] }})
  end
  
  #Checks to see if any items have changed in this project (in the last params[:seconds]). If it has, returns only items that have changed
  def new_dashdata
    if @project.last_item_updated_on.nil?
      @project.last_item_updated_on = DateTime.now
      @project.save
    end
    time_delta = params[:seconds].to_f.round
    if @project.last_item_updated_on.advance(:seconds => time_delta) > DateTime.now
        render :json => Issue.find(:all, :conditions => "project_id = #{@project.id} AND updated_on >= '#{@project.last_item_updated_on.advance(:seconds => -1 * time_delta)}'").to_json(:include => {:journals => {:include => :user}, :issue_votes => {:include => :user}, :status => {:only => :name}, :todos => {:only => [:id, :subject, :completed_on]}, :tracker => {:only => [:name,:id]}, :author => {:only => [:firstname, :lastname, :login, :mail]}, :assigned_to => {:only => [:firstname, :lastname, :login]}})
    else
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
  
  def settings
    @member ||= @project.all_members.new
    @trackers = Tracker.all
    @wiki ||= @project.wiki
  end
  
  # Edit @project
  def edit
    if request.post?
      @project.attributes = params[:project]
      if validate_parent_id && @project.save
        @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'settings', :id => @project
      else
        settings
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
	
  def add_file
    if request.post?
      container = @project
      attachments = attach_files(container, params[:attachments])
      if !attachments.empty? && Setting.notified_events.include?('file_added')
        Mailer.deliver_attachments_added(attachments)
      end
      redirect_to :controller => 'projects', :action => 'list_files', :id => @project
      return
    end
  end
  
  def list_files
    sort_init 'filename', 'asc'
    sort_update 'filename' => "#{Attachment.table_name}.filename",
                'created_on' => "#{Attachment.table_name}.created_on",
                'size' => "#{Attachment.table_name}.filesize",
                'downloads' => "#{Attachment.table_name}.downloads"
                
    @containers = [ Project.find(@project.id, :include => :attachments, :order => sort_clause)]
    render :layout => !request.xhr?
  end

  def team
      @days = Setting.activity_days_default.to_i    
  end

  def credits
    @credits = @project.credits
    @active_credits = @credits.find_all{|credit| credit.enabled == true && credit.settled_on.nil? == true }.group_by{|credit| credit.owner_id}
    @oustanding_credits = @credits.find_all{|credit| credit.settled_on.nil? == true }.group_by{|credit| credit.owner_id}
    @total_credits = @credits.group_by{|credit| credit.owner_id}
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
