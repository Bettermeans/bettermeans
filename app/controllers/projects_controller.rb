# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class ProjectsController < ApplicationController
  
  menu_item :overview
  menu_item :activity, :only => :activity
  menu_item :dashboard, :only => :dashboard
  menu_item :files, :only => [:list_files, :add_file]
  menu_item :settings, :only => :settings
  # menu_item :issues, :only => [:changelog]
  menu_item :team, :only => :team
  menu_item :credits, :only => :credits
  # menu_item :shares, :only => :shares
  
  ssl_required :all  
  
  before_filter :find_project, :except => [ :index, :list, :copy, :activity, :update_scale, :add, :index_active, :index_latest ]
  before_filter :find_optional_project, :only => [:activity, :add]
  # before_filter :authorize, :except => [ :index, :list, :add ]
  #BUGBUG: why aren't these actions being authorized!!!
  before_filter :authorize, :except => [ :index, :index_latest, :index_active, :list, :add, :copy, :archive, :unarchive, :destroy, :activity, :dashboard, :dashdata, :new_dashdata, :mypris, :update_scale, :community_members, :hourly_types ]
  
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
  
  log_activity_streams :current_user, :name, :edited, :@project, :name, :edit, :workstreams, {:object_description_method => :description}
  
  
  # Lists visible projects
  def index
    # @news = News.latest User.current
    # @projects = Project.latest User.current, 10, false
    @latest_enterprises = Project.latest User.current, 10, true
    @active_enterprises = Project.most_active User.current, 10, true
    # @activities_by_item = ActivityStream.fetch(nil, nil, true, 100)
  end
  
  def index_latest
    limit = 10
    @latest_enterprises = Project.latest User.current, limit, true, Integer(params[:offset])
    
    respond_to do |wants|
      wants.js do
        render :update do |page|
          page.replace "project_index_bottom_latest", :partial => "project_list", :locals => { 
                                              :projects => @latest_enterprises,
                                              :offset => Integer(params[:offset]) + limit,
                                              :index_type => 'latest'}
          page.call "display_sparks"
        end
      end
    end
  end
  
  def index_active
    limit = 10
    @active_enterprises = Project.most_active User.current, limit, true, Integer(params[:offset])
    
    respond_to do |wants|
      wants.js do
        render :update do |page|
          page.replace "project_index_bottom_active", :partial => "project_list", :locals => { 
                                              :projects => @active_enterprises,
                                              :offset => Integer(params[:offset]) + limit,
                                              :index_type => 'active'}
          page.call "display_sparks"
        end
      end
    end
  end
  
  def map
  end
  
  # Add a new project
  #TODO too much logic here, needs to move to model somehow
  def add
    @project = Project.new(params[:project])
    @parent = Project.find(params[:parent_id]) unless params[:parent_id] == "" || params[:parent_id].nil?
    
    if request.get?
      @project.enabled_module_names = Setting.default_projects_modules
      @project.dpp = 100

      if @parent
        @project.is_public = @parent.is_public
        @project.volunteer = @parent.volunteer
      end
    else
      @project.enabled_module_names = params[:enabled_modules]
      @project.is_public = params[:project][:is_public] || Setting.default_projects_public?
      @project.owner_id = User.current.id if params[:parent_id] == "" || params[:parent_id].nil?
      @project.homepage = url_for(:controller => 'projects', :action => 'wiki', :id => @project)

      if validate_parent_id && @project.save
        LogActivityStreams.write_single_activity_stream(User.current, :name, @project, :name, :created, :workstreams, 0, nil,{:object_description_method => :description})

        if @parent.nil?          
          # Add current user as a admin and core team member
          # User.current.add_to_project(self, Role::BUILTIN_ADMINISTRATOR)
          # User.current.add_to_project(self, Role::BUILTIN_CORE_MEMBER)
          r = Role.find(Role::BUILTIN_CORE_MEMBER)
          r2 = Role.find(Role::BUILTIN_ADMINISTRATOR)
          m = Member.new(:user => User.current, :roles => [r,r2])
          @project.all_members << m
        else
          @project.set_parent!(@parent.id)  # @project.set_allowed_parent!(@parent.id) unless @parent.nil?
          @project.refresh_active_members
          User.current.add_to_project(@project, Role::BUILTIN_ACTIVE)
        end

        flash.now[:notice] = l(:notice_successful_create)
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
        flash.now[:notice] = l(:notice_successful_create)
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
    
    @subprojects = @project.children.active.find(:all, :order => 'name ASC')
    @news = @project.news.find(:all, :conditions => " (created_at > '#{Time.now.advance :days => (Setting::DAYS_FOR_LATEST_NEWS * -1)}')", :limit => 5, :include => [ :author, :project ], :order => "#{News.table_name}.created_at DESC")
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
    
    # @activities_by_item = ActivityStream.fetch(params[:user_id], @project, params[:with_subprojects], 30)    
    
    
  end
  
  def hourly_types
    render :json => @project.hourly_types.inject({}) { |hash, hourly_type|
      hash[hourly_type.id] = hourly_type.name
      hash
    }.to_json
  end
  
  def community_members
    render :json => @project.root.all_members.inject({}) { |hash, member|
      hash[member.user_id] = member.name
      hash
    }.to_json
  end
  
  def dashboard
    @kufta = "whatever"
    @credit_base = @project.dpp
    @show_issue_id = params[:show_issue_id] #Optional parameter to start the dashboard off showing an issue
    @show_retro_id = params[:show_retro_id] #Optional parameter to start the dashboard off showing a retrospective
  end
  
  #TODO: optimize this query, it's WAY too heavy, and we need fewer columns, and it's executing hundreds of queries!
  def dashdata
    
    if params[:status_ids]
      @conditions = "project_id = #{@project.id} AND (retro_id < 0 OR retro_id is null) AND status_id in (#{params[:status_ids]})"
    else
      @conditions = "project_id = #{@project.id} AND (retro_id < 0 OR retro_id is null)"
    end
    
    render :json => Issue.find(:all, :conditions => @conditions)  \
                         .to_json(:include => { :journals =>    { :only => [:id, :notes, :created_at, :user_id], :include => {:user => { :only => [:firstname, :lastname, :login] }}},
                                                :issue_votes => { :include => {:user => { :only => [:firstname, :lastname, :login] }}},
                                                :status =>      { :only => :name },
                                                :todos =>       { :only => [:id, :subject, :completed_on, :owner_login] },
                                                :tracker =>     { :only => [:name,:id] },
                                                :author =>      { :only => [:firstname, :lastname, :login, :mail_hash] },
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
      render :json => Issue.find(:all, :conditions => "project_id = #{@project.id} AND updated_at >= '#{@project.last_item_updated_on.advance(:seconds => -1 * time_delta)}'").to_json(:include => {:journals => { :only => [:id, :notes, :created_at, :user_id], :include => {:user => { :only => [:firstname, :lastname, :login] }}}, 
                                                                                                                                                                                                            :issue_votes => { :include => {:user => { :only => [:firstname, :lastname, :login] }}}, 
                                                                                                                                                                                                            :status => {:only => :name}, 
                                                                                                                                                                                                            :todos => {:only => [:id, :subject, :completed_on]}, 
                                                                                                                                                                                                            :tracker => {:only => [:name,:id]}, 
                                                                                                                                                                                                            :author => {:only => [:firstname, :lastname, :login, :mail_hash]}, 
                                                                                                                                                                                                            :assigned_to => {:only => [:firstname, :lastname, :login]}})
    elsif params[:issuecount] != @project.issue_count.to_s
      render :json =>  Issue.find(:all, :conditions => {:project_id => @project.id}).collect {|i| i.id}
    else
      render :text => 'no'
    end
  end
  
  def update_scale
    render :update do |page|
      page.replace 'point_scale', :partial => 'point_scale', :locals => {:dpp => params[:dpp] }
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
      old_attributes = @project.attributes
      @project.attributes = params[:project]
      
      if (old_attributes["is_public"] != (params[:project]["is_public"] == "1"))
        description = (params[:project]["is_public"] == "1") ? "publicised" : "privatized"
          LogActivityStreams.write_single_activity_stream(User.current, :name, @project, :name, description, :workstreams, 0, nil,{})
      end
      
      if validate_parent_id && @project.save
        @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
        @project.refresh_active_members
        flash.now[:notice] = l(:notice_successful_update)
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
        flash.now[:error] = l(:error_can_not_archive_project)
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
                'created_at' => "#{Attachment.table_name}.created_at",
                'size' => "#{Attachment.table_name}.filesize",
                'downloads' => "#{Attachment.table_name}.downloads"
                
    @containers = [ Project.find(@project.id, :include => :attachments, :order => sort_clause)]
    render :layout => !request.xhr?
  end

  def team
      @days = Setting.activity_days_default.to_i    
  end

  def credits
    @credits = @project.fetch_credits(params[:with_subprojects])
    @active_credits = @credits.find_all{|credit| credit.enabled == true && credit.settled_on.nil? == true }.group_by{|credit| credit.owner_id}
    @oustanding_credits = @credits.find_all{|credit| credit.settled_on.nil? == true }.group_by{|credit| credit.owner_id}
    @total_credits = @credits.group_by{|credit| credit.owner_id}
  end

#params that can be passed: length, with_subprojects, and author
  def activity
    
    # @activities_by_item = ActivityStream.fetch(params[:user_id], @project, params[:with_subprojects], params[:length])    
    # if events.empty? || stale?(:etag => [events.first, User.current])
    #   respond_to do |format|
    #     format.html { 
    #       @events_by_day = events.group_by(&:event_date)
    #       render :layout => false if request.xhr?
    #     }
    #     format.atom {
    #       title = l(:label_activity)
    #       if @author
    #         title = @author.name
    #       elsif @activity.scope.size == 1
    #         title = l("label_#{@activity.scope.first.singularize}_plural")
    #       end
    #       render_feed(events, :title => "#{@project || Setting.app_title}: #{title}")
    #     }
    #   end
    # end
    
  rescue ActiveRecord::RecordNotFound
    render_404
  end  
  
  # def activity
  #   @days = Setting.activity_days_default.to_i
  #   
  #   if params[:from]
  #     begin; @date_to = params[:from].to_date + 1; rescue; end
  #   end
  # 
  #   @date_to ||= Date.today + 1
  #   @date_from = @date_to - @days
  #   @with_subprojects = params[:with_subprojects].nil? ? Setting.display_subprojects_issues? : (params[:with_subprojects] == '1')
  #   @author = (params[:user_id].blank? ? nil : User.active.find(params[:user_id]))
  #   
  #   @activity = Redmine::Activity::Fetcher.new(User.current, :project => @project, 
  #                                                            :with_subprojects => @with_subprojects,
  #                                                            :author => @author)
  #   @activity.scope_select {|t| !params["show_#{t}"].nil?}
  #   @activity.scope = (@author.nil? ? :default : :all) if @activity.scope.empty?
  # 
  #   events = @activity.events(@date_from, @date_to)
  #   
  #   if events.empty? || stale?(:etag => [events.first, User.current])
  #     respond_to do |format|
  #       format.html { 
  #         @events_by_day = events.group_by(&:event_date)
  #         render :layout => false if request.xhr?
  #       }
  #       format.atom {
  #         title = l(:label_activity)
  #         if @author
  #           title = @author.name
  #         elsif @activity.scope.size == 1
  #           title = l("label_#{@activity.scope.first.singularize}_plural")
  #         end
  #         render_feed(events, :title => "#{@project || Setting.app_title}: #{title}")
  #       }
  #     end
  #   end
  #   
  # rescue ActiveRecord::RecordNotFound
  #   render_404
  # end
  
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
