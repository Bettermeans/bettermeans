# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

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
  
  #BUGBUG: why aren't these actions being authorized!!! archive can be removed, unarchive doesn't seem to work when removed from here
  before_filter :authorize, :except => [ :index, :index_latest, :index_active, :list, :add, :copy, :archive, :unarchive, :destroy, :activity, :dashboard, :dashdata, :new_dashdata, :mypris, :update_scale, :community_members, :community_members_array, :issue_search, :hourly_types, :join]
  
  before_filter :authorize_global, :only => :add
  before_filter :require_admin, :only => [ :copy ]
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
    
  def index    
    @latest_enterprises = Project.latest_public
    @active_enterprises = Project.most_active_public
  end
  
  def index_latest
    limit = 10
    @latest_enterprises = Project.latest nil, limit, true, Integer(params[:offset])
    
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
    @active_enterprises = Project.most_active nil, limit, true, Integer(params[:offset])
    
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
      @project.is_public = params[:project][:is_public] || false
      @project.volunteer = params[:project][:volunteer] || false
      @project.homepage = url_for(:controller => 'projects', :action => 'wiki', :id => @project)
      

      if validate_parent_id && @project.save
        LogActivityStreams.write_single_activity_stream(User.current, :name, @project, :name, :created, :workstreams, 0, nil,{:object_description_method => :description})
        

        if @parent.nil?          
          # Add current user as a admin and core team member
          r = Role.core_member
          r2 = Role.administrator
          m = Member.new(:user => User.current, :roles => [r,r2])
          @project.all_members << m
          @project.update_attribute(:owner_id, User.current.id)
          
        else
          @project.set_parent!(@parent.id)  # @project.set_allowed_parent!(@parent.id) unless @parent.nil?
          @project.set_owner
          @project.refresh_active_members
          User.current.add_to_project(@project, Role.active)
        end
        

        flash.now[:success] = l(:notice_successful_create)        
        redirect_to :controller => 'projects', :action => 'dashboard', :id => @project.id
      else
        redirect_with_flash :error, "Couldn't create project", :controller => "my", :action => "projects"
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
        flash.now[:success] = l(:notice_successful_create)
        redirect_to :controller => 'admin', :action => 'projects'
      end		
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to :controller => 'admin', :action => 'projects'
  end
  
  def reset_invitation_token
    @project.invitation_token = Token.generate_token_value
    @project.save
    
    respond_to do |wants|
      wants.js do
        render :update do |page|
          page.replace "generic-invitation", :partial => 'invitations/generic_invitation', :locals => {:project => @project} 
          page.visual_effect :highlight, "generic-link", :duration => 6
          page.visual_effect :highlight, "generic-invitation", :duration => 2
          page.call '$.jGrowl', l(:notice_successful_update)
        end
      end
    end
  end
  
  def join
    #check token
    if params[:token] != @project.invitation_token
      render_error(l(:error_old_invite))
      return
    else
      #add as contributor
      if @project.root?
        unless User.current.community_member_of? @project
          User.current.add_to_project @project, Role.contributor
          msg = "Invitation accepted. You are now a contributor of #{@project.name}"
          redirect_with_flash :success, msg, :controller => :projects, :action => :show, :id => @project.id
        else
          msg = "You're already on the #{@project.name} team. Invitation ignored"
          redirect_with_flash :error, msg, :controller => :projects, :action => :show, :id => @project.id
        end
        
      # else
      #   @user.add_to_project @project, Role.active.id
      #   @user.add_to_project @project.root, self.role_id unless @user.community_member_of? @project.root
      end
    end
  end
  
  # Show @project
  def overview
    if params[:jump]
      # try to redirect to the requested menu item
      redirect_to_project_menu_item(@project, params[:jump]) && return
    end

    @subprojects = @project.descendants.active
    # @subprojects = @project.children.active
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
  
  def community_members_array
    array = []
    @project.root.member_users.each {|m| array.push({:label => "#{m.user.name} (@#{m.user.login})", :value => m.user.login, :mail_hash => m.user.mail_hash })}
    @project.member_users.each {|m| array.push({:label => "#{m.user.name} (@#{m.user.login})", :value => m.user.login, :mail_hash => m.user.mail_hash }) }
    render :json => array.sort{|x,y| x[:label] <=> y[:label]}.uniq.to_json
  end
  
  def issue_search
    term = params[:searchTerm]
    render :json => Issue.find(:all, :conditions => "project_id = #{@project.id} AND (subject ilike '%#{term}%' OR CAST(id as varchar) ilike '%#{term}%')").to_json(:only => [:id, :subject, :description])
    # @project.each {|m| array.push({:label => "#{m.user.name} (@#{m.user.login})", :value => m.user.login, :mail_hash => m.user.mail_hash })}
    # @project.member_users.each {|m| array.push({:label => "#{m.user.name} (@#{m.user.login})", :value => m.user.login, :mail_hash => m.user.mail_hash }) }
    # render :json => array.sort{|x,y| x[:label] <=> y[:label]}.uniq.to_json
  end
  
  def all_tags
    render :json => @project.all_tags(params[:term]).to_json
  end
  
  
  def dashboard
    @credit_base = @project.dpp
    @show_issue_id = params[:show_issue_id] #Optional parameter to start the dashboard off showing an issue
    @show_retro_id = params[:show_retro_id] #Optional parameter to start the dashboard off showing a retrospective
  end
  
  #TODO: optimize this query, it's WAY too heavy, and we need fewer columns, and it's executing hundreds of queries!
  def dashdata
    
    if params[:include_subworkstreams]
      project_ids = [@project.sub_project_array_visible_to(User.current).join(",")]
    else
      project_ids = [@project.id]
    end
    
    if params[:status_ids]
      conditions = "project_id in (#{project_ids}) AND (retro_id < 0 OR retro_id is null) AND status_id in (#{params[:status_ids]})"
    else
      conditions = "project_id in (#{project_ids}) AND (retro_id < 0 OR retro_id is null)"
    end
    
    render :json => Issue.find(:all, :conditions => conditions)  \
                         .to_json(:include => { :journals =>    { :only => [:id, :notes, :created_at, :user_id], :include => {:user => { :only => [:firstname, :lastname, :login] }}},
                                                :issue_votes => { :include => {:user => { :only => [:firstname, :lastname, :login] }}},
                                                :status =>      { :only => :name },
                                                :attachments => { :only => [:id, :filename]},
                                                :todos =>       { :only => [:id, :subject, :completed_on, :owner_login] },
                                                :tracker =>     { :only => [:name,:id] },
                                                :author =>      { :only => [:firstname, :lastname, :login, :mail_hash] },
                                                :assigned_to => { :only => [:firstname, :lastname, :login] }
                                                },
                                                :except => :tags)
  end
  
  #Checks to see if any items have changed in this project (in the last params[:seconds]). If it has, returns only items that have changed
  def new_dashdata
    if @project.last_item_updated_on.nil?
      @project.last_item_updated_on = DateTime.now
      @project.save
    end
    
    if params[:include_subworkstreams]
      project_ids = [@project.sub_project_array_visible_to(User.current).join(",")]
      total_count = (@project.issue_count + @project.issue_count_sub).to_s
      last_update = @project.last_item_sub_updated_on
    else
      project_ids = [@project.id]
      total_count = @project.issue_count.to_s
      last_update = @project.last_item_updated_on
    end
    
    time_delta = params[:seconds].to_f.round

    conditions = "project_id in (#{project_ids}) AND updated_at >= '#{@project.last_item_updated_on.advance(:seconds => -1 * time_delta)}'"
    
    if (last_update.advance(:seconds => time_delta) > DateTime.now)
      
      render :json => Issue.find(:all, :conditions => conditions).to_json(:include => { :journals =>    { :only => [:id, :notes, :created_at, :user_id], :include => {:user => { :only => [:firstname, :lastname, :login] }}},
                                                  :issue_votes => { :include => {:user => { :only => [:firstname, :lastname, :login] }}},
                                                  :status =>      { :only => :name },
                                                  :attachments => { :only => [:id, :filename]},
                                                  :todos =>       { :only => [:id, :subject, :completed_on, :owner_login] },
                                                  :tracker =>     { :only => [:name,:id] },
                                                  :author =>      { :only => [:firstname, :lastname, :login, :mail_hash] },
                                                  :assigned_to => { :only => [:firstname, :lastname, :login] }
                                                  },
                                                  :except => :tags)
    elsif params[:issuecount] != total_count
      render :json =>  Issue.find(:all, :conditions => "project_id in (#{project_ids})  AND (retro_id < 0 OR retro_id is null)").collect {|i| i.id}
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
    @allow_logo_selection = true
  end
  
  # Edit @project
  def edit
    if request.post?
      old_attributes = @project.attributes
      @project.attributes = params[:project]
      @project.is_public = params[:project][:is_public] || false
      @project.volunteer = params[:project][:volunteer] || false
      
      
      if (old_attributes["is_public"] != (params[:project]["is_public"] == "1"))
        description = (params[:project]["is_public"] == "1") ? "publicised" : "privatized"
          LogActivityStreams.write_single_activity_stream(User.current, :name, @project, :name, description, :workstreams, 0, nil,{})
      end      
      
      if validate_parent_id && @project.save
        @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
        @project.refresh_active_members
        flash.now[:success] = l(:notice_successful_update)
        redirect_to :action => 'settings', :id => @project
      else
        settings
        render :action => 'settings'
      end
    end
  end
  
  def modules
    @project.enabled_module_names = params[:enabled_modules]
    @project.attributes = params[:project]
    @project.save
    redirect_with_flash :notice, l(:notice_successful_update), :action => 'settings', :id => @project, :tab => 'modules'
  end

  def archive
    if @project.active? && request.post? && @project.archive
      project_id_override = @project.parent ? @project.parent.id : @project.id #archived projects don't show up in activity stream, so we log the activity to its parent if it exists
      LogActivityStreams.write_single_activity_stream(User.current, :name, @project, :name, l(:label_archived), :workstreams, 0, nil,{:project_id => project_id_override})
      redirect_with_flash :notice, l(:notice_successful_update), :controller => "my", :action => 'projects'
    else
      render_error(l(:error_general))
    end
  end
  
  def unarchive
    if !@project.active? && request.post? && @project.unarchive
      LogActivityStreams.write_single_activity_stream(User.current, :name, @project, :name, l(:label_unarchived), :workstreams, 0, nil,{})
    
      respond_to do |wants|
      
        wants.js do
          @my_projects = User.current.owned_projects
          
          render :update do |page|
            page.replace params[:table_id], :partial => 'my/my_projects', :locals => {:my_projects => @my_projects, :table_id => params[:table_id]}
            page.call '$.jGrowl', l(:notice_successful_update)
            page.call 'display_sparks'
          end
        end
      end
    else
      respond_to do |wants|      
        wants.js do
          render :update do |page|
            page.call '$.jGrowl', l(:error_general)
          end
        end
      end
    end
  end
  
  # Delete @project
  def destroy
    @project_to_destroy = @project
    if request.post?
      project_id_override = @project.parent ? @project.parent.id : @project.id #deleted projects don't show up in activity stream, so we log the activity to its parent if it exists
      LogActivityStreams.write_single_activity_stream(User.current, :name, @project, :name, l(:label_deleted), :workstreams, 0, nil,{:project_id => project_id_override})
      if @project_to_destroy.destroy
        redirect_with_flash :notice, l(:notice_successful_delete), :controller => "welcome", :action => 'index'
      else
        render_error(l(:error_general))
      end
    end
    # hide project in layout
    @project = nil
  end

  #move project
  def move
    redirect_to(:action => 'settings') and return if @project.root?

    #TODO @project.allowed_parents should be used but it isn't working correctly currently
    @allowed_projects = []
    disallowed_projects = @project.self_and_descendants
    @project.root.self_and_descendants.each {|p| @allowed_projects << p if p.visible_to(User.current) && !disallowed_projects.include?(p) }

    if request.post?
      if (parent = Project.find params[:parent_id]) && @allowed_projects.include?(parent)
        @project.move_to_child_of(parent)
        flash[:success] = l(:notice_successful_update)
        LogActivityStreams.write_single_activity_stream(User.current, :name, @project, :name, l(:label_moved), :workstreams, 0, nil,{:project_id => @project.id})
        redirect_to @project
      else
        render_403 and return
      end
    end
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
      @hide_view_team_link = true #hides the link to this page from the active box
  end

  def credits
    @credits = @project.fetch_credits(params[:with_subprojects])
    
    @credits_pages, @creditss = @project.fetch_credits(params[:with_subprojects])
    
    
    @active_credits = @credits.find_all{|credit| credit.enabled == true && credit.settled_on.nil? == true }.group_by{|credit| credit.owner_id}
    @oustanding_credits = @credits.find_all{|credit| credit.settled_on.nil? == true }.group_by{|credit| credit.owner_id}
    @total_credits = @credits.group_by{|credit| credit.owner_id}
  end

  #params that can be passed: length, with_subprojects, and author
  def activity
    
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
    render_message l(:text_project_locked) if @project.locked?
    
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
