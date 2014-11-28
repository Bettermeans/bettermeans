# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class IssuesController < ApplicationController
  menu_item :new_issue, :only => :new
  default_search_scope :issues
  ssl_required :all

  # BUGBUG: :disagree and :reject don't seem to be used anymore
  before_filter :find_issue, :only => [:show, :edit, :reply, :start, :finish, :release, :cancel, :restart, :prioritize, :agree, :disagree, :accept, :reject, :estimate, :join, :leave, :add_team_member, :remove_team_member, :move, :update_tags]
  before_filter :find_issues, :only => [:bulk_edit, :move, :destroy]
  before_filter :find_project, :only => [:new, :update_form, :preview]
  before_filter :authorize, :except => [:index, :changes, :gantt, :calendar, :preview, :context_menu, :datadump, :temp]
  before_filter :find_optional_project, :only => [:index, :changes, :gantt, :calendar]
  accept_key_auth :index, :show, :changes

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :journals
  helper :projects
  include ProjectsHelper
  helper :issue_relations
  include IssueRelationsHelper
  helper :watchers
  include WatchersHelper
  helper :attachments
  include AttachmentsHelper
  helper :queries
  helper :sort
  include SortHelper
  include IssuesHelper
  include Redmine::Export::PDF

  verify :method => :post,
         :only => :destroy,
         :render => { :nothing => true, :status => :method_not_allowed}

  log_activity_streams :current_user, :name, :added, :@issue, :subject, :new, :issues, {:object_description_method => :description}
  log_activity_streams :current_user, :name, :finished, :@issue, :subject, :finish, :issues, {
    :object_description_method => :description,
    :indirect_object => :@journal,
    :indirect_object_description_method => :notes,
    :indirect_object_phrase => '' }

  log_activity_streams :current_user, :name, :started, :@issue, :subject, :start, :issues, {:object_description_method => :description}
  log_activity_streams :current_user, :name, :gave_up_on, :@issue, :subject, :release, :issues, {:object_description_method => :description}
  log_activity_streams :current_user, :name, :canceled, :@issue, :subject, :cancel, :issues, {
    :object_description_method => :description,
    :indirect_object => :@journal,
    :indirect_object_description_method => :notes,
    :indirect_object_phrase => '' }
  log_activity_streams :current_user, :name, :joined, :@issue, :subject, :join, :issues, {:object_description_method => :description}
  log_activity_streams :current_user, :name, :left, :@issue, :subject, :leave, :issues, {:object_description_method => :description}
  log_activity_streams :current_user, :name, :updated, :@issue, :subject, :edit, :issues,{
    :object_description_method => :description,
    :indirect_object => :@journal,
    :indirect_object_description_method => :notes,
    :indirect_object_phrase => 'GENERATEDETAILS' } #special value generates details for each property change

  log_activity_streams :current_user, :name, :restarted, :@issue, :subject, :restart, :issues, {}

  def index # spec_me cover_me heckle_me
    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update({'id' => "#{Issue.table_name}.id"}.merge(@query.available_columns.inject({}) {|h, c| h[c.name.to_s] = c.sortable; h}))

    if @query.valid?
      limit = per_page_option
      respond_to do |format|
        format.html { }
        format.csv  { limit = Setting.issues_export_limit.to_i }
        format.pdf  { limit = Setting.issues_export_limit.to_i }
      end

      @issue_count = @query.issue_count
      @issue_pages = Paginator.new self, @issue_count, limit, params['page']
      @issues = @query.issues(:include => [:assigned_to, :tracker],
                              :order => sort_clause,
                              :offset => @issue_pages.current.offset,
                              :limit => limit)
      @issue_count_by_group = @query.issue_count_by_group

      respond_to do |format|
        format.html { render :template => 'issues/index.html.erb', :layout => !request.xhr? }
        format.csv  { send_data(issues_to_csv(@issues, @project), :type => 'text/csv; header=present', :filename => 'export.csv') }
        format.pdf  { send_data(issues_to_pdf(@issues, @project, @query), :type => 'application/pdf', :filename => 'export.pdf') }
      end
    else
      # Send html if the query is not valid
      render(:template => 'issues/index.html.erb', :layout => !request.xhr?)
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def show # spec_me cover_me heckle_me
    @journals = @issue.journals.find(:all, :include => [:user, :details], :order => "#{Journal.table_name}.created_at ASC")
    @journals.each_with_index {|j,i| j.indice = i+1}
    @journals.reverse! if User.current.wants_comments_in_reverse_order?
    @edit_allowed = true
    @edit_allowed = @issue.editable? && User.current.allowed_to?(:edit_issues, @project)

    respond_to do |format|
      format.html { render :template => 'issues/show.html.erb', :layout => 'issue_blank' }
      format.pdf  { send_data(issue_to_pdf(@issue), :type => 'application/pdf', :filename => "#{@project.identifier}-#{@issue.id}.pdf") }
    end
  end

  # Add a new issue
  # The new issue will be created from an existing one if copy_from parameter is given
  def new # spec_me cover_me heckle_me
    @issue = Issue.new
    @issue.copy_from(params[:copy_from]) if params[:copy_from]
    @issue.project = @project
    @issue.tracker ||= Tracker.find(params[:tracker_id] || :first || params[:issue][:tracker_id])
    if @issue.tracker.nil?
      raise 'no tracker!'
      render_error l(:error_no_tracker_in_project)
      return
    end
    if params[:issue].is_a?(Hash)
      @issue.attributes = params[:issue]
      @issue.watcher_user_ids = params[:issue]['watcher_user_ids'] if User.current.allowed_to?(:add_issue_watchers, @project)
    end
    @issue.author = User.current


    default_status = IssueStatus.default
    unless default_status
      raise 'no default status!'
      render_error l(:error_no_default_issue_status)
      return
    end
    @issue.status = default_status
    @allowed_statuses = ([default_status] + default_status.find_new_statuses_allowed_to(User.current.roles_for_project(@project), @issue.tracker)).uniq

    if request.get?
      @issue.start_date ||= Date.today
    else
      if params[:issue].nil? || params[:issue][:status_id].nil?
        requested_status = default_status
      else
        requested_status = IssueStatus.find_by_id(params[:issue][:status_id])
      end

      @issue.status = requested_status
      @issue.tag_list = @issue.tags_copy if @issue.tags_copy

      if @issue.save
        Mention.parse(@issue, User.current.id)
        attach_files_for_new_issue(@issue, params[:attachments])

        #adding self-agree vote
        @iv = IssueVote.create :issue_id => @issue.id, :user_id => User.current.id, :points => 1, :vote_type => IssueVote::AGREE_VOTE_TYPE
        @issue.update_agree_total @iv.isbinding

        #dealing with the estimate
        if params[:estimate] && params[:estimate] != ""  #-2 means that nothing was chosen
          @iv = IssueVote.create :issue_id => @issue.id, :user_id => User.current.id, :points => params[:estimate].to_i, :vote_type => IssueVote::ESTIMATE_VOTE_TYPE
          @issue.update_estimate_total @iv.isbinding
        end

        #dealing with prioritizing
        if params[:prioritize] == "true"
          @iv = IssueVote.create :issue_id => @issue.id, :user_id => User.current.id, :points => 1, :vote_type => IssueVote::PRI_VOTE_TYPE
          @issue.update_pri_total @iv.isbinding
        end

        @issue.save! unless @issue.update_status

        @issue.reload

        respond_to do |format|
          format.js {render :json => @issue.to_dashboard}
          format.html {redirect_to(params[:continue] ? { :action => 'new', :tracker_id => @issue.tracker } :
                                        { :action => 'show', :id => @issue })}
        end
        return
      else
        respond_to do |format|
          format.js {render :text => nil}
          format.html { render :action => "new" }
        end
        return
      end
    end

    render :layout => !request.xhr?
  end

  # Attributes that can be updated on workflow transition (without :edit permission)
  # TODO: make it configurable (at least per role)
  UPDATABLE_ATTRS_ON_TRANSITION = %w(status_id assigned_to_id done_ratio) unless const_defined?(:UPDATABLE_ATTRS_ON_TRANSITION)

  def edit # spec_me cover_me heckle_me
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    @edit_allowed = @issue.editable? && User.current.allowed_to?(:edit_issues, @project)

    @notes = params[:notes]
    @journal = @issue.init_journal(User.current, @notes)
    # User can change issue attributes only if he has :edit permission or if a workflow transition is allowed
    if (@edit_allowed || !@allowed_statuses.empty?) && params[:issue]
      attrs = params[:issue].dup
      attrs.delete_if {|k,v| !UPDATABLE_ATTRS_ON_TRANSITION.include?(k) } unless @edit_allowed
      attrs.delete(:status_id) unless @allowed_statuses.detect {|s| s.id.to_s == attrs[:status_id].to_s}
      @issue.attributes = attrs
    end

    if request.post?
      attachments = attach_files(@issue, params[:attachments])
      attachments.each {|a| @journal.details << JournalDetail.new(:property => 'attachment', :prop_key => a.id, :value => a.filename)}

      if @issue.save
        Mention.parse(@issue, User.current.id)

        @issue.reload
        respond_to do |format|
          format.js {render :json => @issue.to_dashboard}
          format.html {redirect_to(params[:back_to] || {:action => 'show', :id => @issue})}
        end
      end
    end
  rescue ActiveRecord::StaleObjectError
    # Optimistic locking exception
    flash.now[:error] = l(:notice_locking_conflict)
    # Remove the previously added attachments if issue was not updated
    attachments.each(&:destroy)
  end

  def start # spec_me cover_me heckle_me
    @in_progress = Issue.count(:conditions => {:assigned_to_id => User.current.id, :status_id => IssueStatus.assigned.id, :project_id => @issue.project_id})
    if @in_progress >= Setting::MAXIMUM_CONCURRENT_REQUESTS
      render_error "Maximum issues owned by this user already"
      return false;
    else
      IssueVote.create :user_id => User.current.id, :issue_id => params[:id], :vote_type => IssueVote::JOIN_VOTE_TYPE, :points => 1 #Joins as first person on the team
      IssueVote.delete_all :issue_id => params[:id], :vote_type => IssueVote::ACCEPT_VOTE_TYPE
      params[:issue] = {:status_id => IssueStatus.assigned.id, :assigned_to_id => User.current.id}
      change_status
    end
  end

  def finish # spec_me cover_me heckle_me
    params[:issue] = {:status_id => IssueStatus.done.id}
    @iv = IssueVote.create :user_id => User.current.id, :issue_id => @issue.id, :vote_type => IssueVote::ACCEPT_VOTE_TYPE, :points => 1 #adding accept vote for user who finished the issue
    @issue.update_accept_total  @iv.isbinding
    @issue.clone_recurring if @issue.tracker.recurring?
    @issue.set_points_from_hourly if @issue.hourly? #an hourly item is done, we set the
    change_status
  end

  def release # spec_me cover_me heckle_me
    if(@issue.hourly?)
      params[:issue] = {:status_id => IssueStatus.newstatus.id, :assigned_to_id => ''}
    else
      #Deleting current user from issue
      IssueVote.delete_all(["user_id = ? AND issue_id = ? AND vote_type = ?", User.current.id, params[:id], IssueVote::JOIN_VOTE_TYPE])

      #Check to see if anybody else is on the issue, if they are assign the issue to them
      next_team_member = @issue.team_members.first
      if next_team_member.nil?
        new_status_id = IssueStatus.open.id
        params[:issue] = {:status_id => IssueStatus.open.id, :assigned_to_id => ''}
      else
        params[:issue] = {:assigned_to_id => next_team_member.id}
      end
    end

    change_status
  end

  def cancel # spec_me cover_me heckle_me
    params[:issue] = {:status_id => IssueStatus.canceled.id}
    change_status
  end

  def restart # spec_me cover_me heckle_me
    params[:issue] = {:status_id => IssueStatus.newstatus.id}
    change_status
  end

  def change_status # spec_me cover_me heckle_me
      @notes = params[:notes]
      @journal = @issue.init_journal(User.current, @notes)

        attrs = params[:issue].dup
        @issue.attributes = attrs

      if @issue.save
        respond_to do |format|
          @issue.reload
          format.js {render :json => @issue.to_dashboard}
          format.html {redirect_to(params[:back_to] || {:action => 'show', :id => @issue})}
        end
      end
    rescue ActiveRecord::StaleObjectError
      # Optimistic locking exception
      flash.now[:error] = l(:notice_locking_conflict)
  end

  def prioritize # spec_me cover_me heckle_me
    @iv = IssueVote.create :user_id => User.current.id, :issue_id => params[:id], :vote_type => IssueVote::PRI_VOTE_TYPE, :points => params[:points]
    @issue.update_pri_total @iv.isbinding
    @issue.save!
    @issue.reload
    respond_to do |format|
      format.js {render :json => @issue.to_dashboard}
      format.html {redirect_to(params[:back_to] || {:action => 'show', :id => @issue})}
    end
  end

  def update_tags # spec_me cover_me heckle_me
    @issue.send_later(:update_tags,params[:tags])

    respond_to do |format|
      format.js {render :nothing => true}
      format.html {redirect_to(params[:back_to] || {:action => 'show', :id => @issue})}
    end
  end


  def estimate # spec_me cover_me heckle_me
    if(@issue.hourly?)
      render_error 'Can not estimate hourly items'
      return false;
    end

    @journal = @issue.init_journal(User.current, params["notes"])

    @iv = IssueVote.create :user_id => User.current.id, :issue_id => params[:id], :vote_type => IssueVote::ESTIMATE_VOTE_TYPE, :points => params[:points]
    logger.info { "before update #{@issue.inspect}" }
    @issue.update_estimate_total @iv.isbinding
    logger.info { "after update #{@issue.inspect}" }
    logger.info { "start saving" }
    @issue.save! unless @issue.update_status
    logger.info { "done saving #{@issue.inspect}" }
    @issue.reload

    respond_to do |format|
      format.js {render :json => @issue.to_dashboard}
      format.html {redirect_to(params[:back_to] || {:action => 'show', :id => @issue})}
    end
  end


  def agree # spec_me cover_me heckle_me
    @iv = IssueVote.create :user_id => User.current.id, :issue_id => params[:id], :vote_type => IssueVote::AGREE_VOTE_TYPE, :points => params[:points]
    journal = @issue.init_journal(User.current, params[:notes]) if params[:notes]
    @issue.update_agree_total @iv.isbinding
    @issue.save! unless @issue.update_status
    @issue.reload

    if params[:notes]
      action = :updated
      logger.info { "action is #{params[:points]}" }
      case params[:points]
      when "-1"
        action = "voted against"
      when "-9999"
        action = :blocked
      end

      LogActivityStreams.write_single_activity_stream(User.current,:name,@issue,:subject,action,:issues, 0, journal,{
          :indirect_object_description_method => :notes,
          :indirect_object_phrase => 'GENERATEDETAILS' })
    end

    respond_to do |format|
      format.js {render :json => @issue.to_dashboard}
      format.html {redirect_to(params[:back_to] || {:action => 'show', :id => @issue})}
    end
  end


  def accept # spec_me cover_me heckle_me
    @iv = IssueVote.create :user_id => User.current.id, :issue_id => params[:id], :vote_type => IssueVote::ACCEPT_VOTE_TYPE, :points => params[:points]
    journal = @issue.init_journal(User.current, params[:notes]) if params[:notes]
    @issue.update_accept_total  @iv.isbinding
    @issue.save! unless @issue.update_status
    @issue.reload

    if params[:notes]
      action = :updated
      case params[:points]
      when "-1"
        action = :rejected
      when "-9999"
        action = :blocked_acceptance_of
      end

      LogActivityStreams.write_single_activity_stream(User.current,:name,@issue,:subject,action,:issues, 0, journal,{
          :indirect_object_description_method => :notes,
          :indirect_object_phrase => 'GENERATEDETAILS' })
    end


    respond_to do |format|
      format.js {render :json => @issue.to_dashboard}
      format.html {redirect_to(params[:back_to] || {:action => 'show', :id => @issue})}
    end
  end

  def join # spec_me cover_me heckle_me
    IssueVote.create :user_id => User.current.id, :issue_id => params[:id], :vote_type => IssueVote::JOIN_VOTE_TYPE, :points => 1
    @issue.save!
    @issue.reload

    Notification.create :recipient_id => @issue.assigned_to_id,
                        :variation => 'issue_joined',
                        :params => {:issue_id => @issue.id},
                        :sender_id => User.current.id,
                        :source_id => @issue.id,
                        :source_type => "Issue"


    respond_to do |format|
      format.js {render :json => @issue.to_dashboard}
      format.html {redirect_to(params[:back_to] || {:action => 'show', :id => @issue})}
    end
  end

  def add_team_member # spec_me cover_me heckle_me
    IssueVote.create :user_id => params[:issue_vote][:user_id], :issue_id => params[:id], :vote_type => IssueVote::JOIN_VOTE_TYPE, :points => 1
    @issue.save!
    @issue.reload

    Notification.create :recipient_id => params[:issue_vote][:user_id],
                        :variation => 'issue_team_member_added',
                        :params => {:issue_id => @issue.id, :joiner_id => params[:issue_vote][:user_id]},
                        :sender_id => User.current.id,
                        :source_id => @issue.id,
                        :source_type => "Issue"


    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace "joined_by_partial", :partial => 'issues/joined_by'
          page.visual_effect :highlight, "joined_by_partial"
        end
      end
    end
  end

  def remove_team_member # spec_me cover_me heckle_me
    IssueVote.delete_all :user_id => params[:user_id], :issue_id => params[:id], :vote_type => IssueVote::JOIN_VOTE_TYPE

    Notification.create :recipient_id => params[:user_id],
                        :variation => 'issue_team_member_removed',
                        :params => {:issue_id => @issue.id, :joiner_id => params[:user_id]},
                        :sender_id => User.current.id,
                        :source_id => @issue.id,
                        :source_type => "Issue"

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace "joined_by_partial", :partial => 'issues/joined_by'
          page.visual_effect :highlight, "joined_by_partial"
        end
      end
    end
  end


  def leave # spec_me cover_me heckle_me
    IssueVote.delete_all(["user_id = ? AND issue_id = ? AND vote_type = ?", User.current.id, params[:id], IssueVote::JOIN_VOTE_TYPE])
    @issue.save!
    @issue.reload

    admin = User.sysadmin
    Notification.create :recipient_id => @issue.assigned_to_id,
                        :variation => 'issue_left',
                        :params => {:issue => @issue, :joiner => User.current},
                        :sender_id => User.current.id,
                        :source_id => @issue.id,
                        :source_type => "Issue"


    respond_to do |format|
      format.js {render :json => @issue.to_dashboard}
      format.html {redirect_to(params[:back_to] || {:action => 'show', :id => @issue})}
    end
  end

  def reply # spec_me cover_me heckle_me
    journal = Journal.find(params[:journal_id]) if params[:journal_id]
    if journal
      user = journal.user
      text = journal.notes
    else
      user = @issue.author
      text = @issue.description
    end
    content = "#{ll(Setting.default_language, :text_user_wrote, user)}\\n> "
    content << text.to_s.strip.gsub(%r{<pre>((.|\s)*?)</pre>}m, '[...]').gsub('"', '\"').gsub(/(\r?\n|\r\n?)/, "\\n> ") + "\\n\\n"
    render(:update) { |page|
      page.<< "$('notes').value = \"#{content}\";"
      page.show 'update'
      page << "$('#notes').focus();"
      page << "$('body').scrollTo('#update');"
    }
  end

  # Bulk edit a set of issues
  def bulk_edit # spec_me cover_me heckle_me
    if request.post?
      tracker = params[:tracker_id].blank? ? nil : @project.trackers.find_by_id(params[:tracker_id])
      status = params[:status_id].blank? ? nil : IssueStatus.find_by_id(params[:status_id])
      assigned_to = (params[:assigned_to_id].blank? || params[:assigned_to_id] == 'none') ? nil : User.find_by_id(params[:assigned_to_id])

      unsaved_issue_ids = []
      @issues.each do |issue|
        journal = issue.init_journal(User.current, params[:notes])
        issue.tracker = tracker if tracker
        issue.assigned_to = assigned_to if assigned_to || params[:assigned_to_id] == 'none'
        issue.start_date = params[:start_date] unless params[:start_date].blank?
        issue.due_date = params[:due_date] unless params[:due_date].blank?
        issue.done_ratio = params[:done_ratio] unless params[:done_ratio].blank?
        # Don't save any change to the issue if the user is not authorized to apply the requested status
        unless (status.nil? || (issue.new_statuses_allowed_to(User.current).include?(status) && issue.status = status)) && issue.save
          # Keep unsaved issue ids to display them in flash error
          unsaved_issue_ids << issue.id
        end
      end
      if unsaved_issue_ids.empty?
        flash.now[:success] = l(:notice_successful_update) unless @issues.empty?
      else
        flash.now[:error] = l(:notice_failed_to_save_issues, :count => unsaved_issue_ids.size,
                                                         :total => @issues.size,
                                                         :ids => '#' + unsaved_issue_ids.join(', #'))
      end
      redirect_to(params[:back_to] || {:controller => 'issues', :action => 'index', :project_id => @project})
      return
    end
    @available_statuses = Workflow.available_statuses(@project)
  end

  def move # spec_me cover_me heckle_me
    @copy = params[:copy_options] && params[:copy_options][:copy]
    @allowed_projects = []
    # find projects to which the user is allowed to move the issue
    if User.current.admin?
      # admin is allowed to move issues to any active (visible) project
      @allowed_projects = Project.find(:all, :conditions => Project.visible_by(User.current))
    else
      @issue.project.root.self_and_descendants.each {|p| @allowed_projects << p if p.visible_to(User.current)}
    end

    @target_project = @allowed_projects.detect {|p| p.id.to_s == params[:new_project_id]} if params[:new_project_id]
    @target_project ||= @project
    @trackers = @target_project.trackers
    @available_statuses = Workflow.available_statuses(@project)
    if request.post?
      new_tracker = params[:new_tracker_id].blank? ? nil : @target_project.trackers.find_by_id(params[:new_tracker_id])
      unsaved_issue_ids = []
      moved_issues = []
      @issues.each do |issue|
        changed_attributes = {}
        [:assigned_to_id, :status_id, :start_date, :due_date].each do |valid_attribute|
          unless params[valid_attribute].blank?
            changed_attributes[valid_attribute] = (params[valid_attribute] == 'none' ? nil : params[valid_attribute])
          end
        end
        issue.init_journal(User.current)
        if r = issue.move_to(@target_project, new_tracker, {:copy => @copy, :attributes => changed_attributes})
          LogActivityStreams.write_single_activity_stream(User.current,:name,issue,:subject,:moved,:move, 0, @target_project, {
                    :indirect_object_name_method => :name,
                    :indirect_object_description_method => :name,
                    :indirect_object_phrase => 'to ' })
          moved_issues << r
        else
          unsaved_issue_ids << issue.id
        end
      end
      @project.project.send_later :refresh_issue_count
      if unsaved_issue_ids.empty?
      else
        flash.now[:error] = l(:notice_failed_to_save_issues, :count => unsaved_issue_ids.size,
                                                         :total => @issues.size,
                                                         :ids => '#' + unsaved_issue_ids.join(', #'))
      end
      if params[:follow]
        if @issues.size == 1 && moved_issues.size == 1
          redirect_to :controller => 'projects', :action => 'dashboard', :id => (@target_project || @project), :show_issue_id => moved_issues.first
        else
          redirect_to :controller => 'projects', :action => 'dashboard', :id => (@target_project || @project)
        end
      else
        redirect_to :controller => 'projects', :action => 'dashboard', :id => @project
      end
      return
    end
    render :layout => false if request.xhr?
  end

  def destroy # spec_me cover_me heckle_me
    @issues.each(&:destroy)
    redirect_to :action => 'index', :project_id => @project
  end

  def gantt # spec_me cover_me heckle_me
    @gantt = Redmine::Helpers::Gantt.new(params)
    retrieve_query
    if @query.valid?
      events = []
      # Issues that have start and due dates
      events += @query.issues(:include => [:tracker, :assigned_to],
                              :order => "start_date, due_date",
                              :conditions => ["(((start_date>=? and start_date<=?) or (due_date>=? and due_date<=?) or (start_date<? and due_date>?)) and start_date is not null and due_date is not null)", @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to]
                              )
      # Issues that don't have a due date but that are assigned to a version with a date
      events += @query.issues(:include => [:tracker, :assigned_to],
                              :order => "start_date, effective_date",
                              :conditions => ["(((start_date>=? and start_date<=?) or (effective_date>=? and effective_date<=?) or (start_date<? and effective_date>?)) and start_date is not null and due_date is null and effective_date is not null)", @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to]
                              )

      @gantt.events = events
    end

    basename = (@project ? "#{@project.identifier}-" : '') + 'gantt'

    respond_to do |format|
      format.html { render :template => "issues/gantt.html.erb", :layout => !request.xhr? }
      format.png  { send_data(@gantt.to_image, :disposition => 'inline', :type => 'image/png', :filename => "#{basename}.png") } if @gantt.respond_to?('to_image')
      format.pdf  { send_data(gantt_to_pdf(@gantt, @project), :type => 'application/pdf', :filename => "#{basename}.pdf") }
    end
  end

  def calendar # spec_me cover_me heckle_me
    if params[:year] and params[:year].to_i > 1900
      @year = params[:year].to_i
      if params[:month] and params[:month].to_i > 0 and params[:month].to_i < 13
        @month = params[:month].to_i
      end
    end
    @year ||= Date.today.year
    @month ||= Date.today.month

    @calendar = Redmine::Helpers::Calendar.new(Date.civil(@year, @month, 1), current_language, :month)
    retrieve_query
    if @query.valid?
      events = []
      events += @query.issues(:include => [:tracker, :assigned_to],
                              :conditions => ["((start_date BETWEEN ? AND ?) OR (due_date BETWEEN ? AND ?))", @calendar.startdt, @calendar.enddt, @calendar.startdt, @calendar.enddt]
                              )

      @calendar.events = events
    end

    render :layout => false if request.xhr?
  end

  def context_menu # spec_me cover_me heckle_me
    @issues = Issue.find_all_by_id(params[:ids], :include => :project)
    if (@issues.size == 1)
      @issue = @issues.first
      @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    end
    projects = @issues.collect(&:project).compact.uniq
    @project = projects.first if projects.size == 1

    @can = {:edit => (@project && User.current.allowed_to?(:edit_issues, @project)),
            :update => (@project && (User.current.allowed_to?(:edit_issues, @project) || (User.current.allowed_to?(:change_status, @project) && @allowed_statuses && !@allowed_statuses.empty?))),
            :move => (@project && User.current.allowed_to?(:move_issues, @project)),
            :copy => (@issue && @project.trackers.include?(@issue.tracker) && User.current.allowed_to?(:add_issues, @project)),
            :delete => (@project && User.current.allowed_to?(:delete_issues, @project))
            }
    if @project
      @assignables = @project.assignable_users
      @assignables << @issue.assigned_to if @issue && @issue.assigned_to && !@assignables.include?(@issue.assigned_to)
      @trackers = @project.trackers
    end

    @statuses = IssueStatus.find(:all, :order => 'position')
    @back = params[:back_url] || request.env['HTTP_REFERER']

    render :layout => false
  end

  def update_form # spec_me cover_me heckle_me
    if params[:id].blank?
      @issue = Issue.new
      @issue.project = @project
    else
      @issue = @project.issues.visible.find(params[:id])
    end
    @issue.attributes = params[:issue]
    @allowed_statuses = ([@issue.status] + @issue.status.find_new_statuses_allowed_to(User.current.roles_for_project(@project), @issue.tracker)).uniq

    render :partial => 'attributes'
  end

  def preview # spec_me cover_me heckle_me
    @issue = @project.issues.find_by_id(params[:id]) unless params[:id].blank?
    @attachements = @issue.attachments if @issue
    @text = params[:notes] || (params[:issue] ? params[:issue][:description] : nil)
    render :partial => 'common/preview'
  end

  def datadump # cover_me heckle_me
    project_ids = User.current.owned_projects.map(&:id)
    @issues = Issue.find(:all, :conditions => ['project_id IN (?)', project_ids])
    render :csv => @issues
  end

  private

  def find_issue # cover_me heckle_me
    @issue = Issue.find(params[:id], :include => [:project, :tracker, :status, :author])
    @project = @issue.project
    render_message l(:text_project_locked) if @project.locked?
    render_404 if @issue.gift? && @issue.assigned_to_id == User.current.id
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Filter for bulk operations
  def find_issues # cover_me heckle_me
    @issues = Issue.find_all_by_id(params[:id] || params[:ids])
    raise ActiveRecord::RecordNotFound if @issues.empty?
    projects = @issues.collect(&:project).compact.uniq
    if projects.size == 1
      @project = projects.first
    else
      # TODO: let users bulk edit/move/destroy issues from different projects
      render_error 'Can not bulk edit/move/destroy issues from different projects'
      return false
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project # cover_me heckle_me
    @project = Project.find(params[:project_id])
    render_message l(:text_project_locked) if @project.locked?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_optional_project # cover_me heckle_me
    @project = Project.find(params[:project_id]) unless params[:project_id].blank?
    allowed = User.current.allowed_to?({:controller => params[:controller], :action => params[:action]}, @project, :global => true)
    allowed ? true : deny_access
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Retrieve query from session or build a new query
  def retrieve_query # cover_me heckle_me
    if !params[:query_id].blank?
      cond = "project_id IS NULL"
      cond << " OR project_id = #{@project.id}" if @project
      @query = Query.find(params[:query_id], :conditions => cond)
      @query.project = @project
      session[:query] = {:id => @query.id, :project_id => @query.project_id}
      sort_clear
    else
      if params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
        # Give it a name, required to be valid
        @query = Query.new(:name => "_")
        @query.project = @project
        if params[:fields] and params[:fields].is_a? Array
          params[:fields].each do |field|
            @query.add_filter(field, params[:operators][field], params[:values][field])
          end
        else
          @query.available_filters.keys.each do |field|
            @query.add_short_filter(field, params[field]) if params[field]
          end
        end
        @query.group_by = params[:group_by]
        @query.column_names = params[:query] && params[:query][:column_names]
        session[:query] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names}
      else
        @query = Query.find_by_id(session[:query][:id]) if session[:query][:id]
        @query ||= Query.new(:name => "_", :project => @project, :filters => session[:query][:filters], :group_by => session[:query][:group_by], :column_names => session[:query][:column_names])
        @query.project = @project
      end
    end
  end

  # Rescues an invalid query statement. Just in case...
  def query_statement_invalid(exception) # cover_me heckle_me
    logger.error "Query::StatementInvalid: #{exception.message}" if logger
    session.delete(:query)
    sort_clear
    render_error "An error occurred while executing the query and has been logged. Please report this error to your Redmine administrator."
  end

  def attach_files_for_new_issue(issue, attachment_ids) # cover_me heckle_me
    if attachment_ids
      Attachment.update_all("container_id = #{issue.id}" , "id in (#{attachment_ids}) and container_id = 0" )
    end
  end

end
