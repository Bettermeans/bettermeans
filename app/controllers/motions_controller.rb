class MotionsController < ApplicationController

  before_filter :find_project, :only => [:new,:index,:create,:show, :edit, :eligible_users]
  before_filter :find_motion, :only => [:show, :edit, :destroy, :update, :reply]
  before_filter :check_visibility_permission, :only => [:show]
  before_filter :require_admin, :only => [:edit, :update, :destroy]
  before_filter :authorize, :except => [:check_visibility_permission]
  ssl_required :all


  def index # heckle_me
    @motions = @project.motions
    respond_to do |format|
      format.html
      format.xml  { render :xml => @motions }
    end
  end

  def show # heckle_me
    if @motion.concerned_user_id == User.current.id
      render_403
      return false
    end

    @motion.create_forum_topic if @motion.topic.nil?

    @topic = @motion.topic
    @board = @topic.board
    @replies = @topic.children.find(:all, :include => [:author, :attachments, {:board => :project}])
    @replies.reverse! if User.current.wants_comments_in_reverse_order?
    @reply = Message.new(:subject => "RE: #{@topic.subject}")

    respond_to do |format|
      format.html
      format.xml  { render :xml => @motion }
    end
  end

  def new # spec_me cover_me heckle_me
    @motion = Motion.new(params[:motion])

    @concerned_user_list = Motion.eligible_users(@motion.variation, @project.id)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @motion }
    end
  end

  def eligible_users # spec_me cover_me heckle_me
    @concerned_user_list = ""
    @variation = params[:variation].to_i
    case @variation
      when Motion::VARIATION_NEW_MEMBER
        @concerned_user_list = @project.contributor_list
      when Motion::VARIATION_NEW_CORE
        @concerned_user_list = @project.member_list
      when Motion::VARIATION_FIRE_MEMBER
        @concerned_user_list = @project.member_list
      when Motion::VARIATION_FIRE_CORE
        @concerned_user_list = @project.core_member_list
    end

    @concerned_user_list = [] if @concerned_user_list == ""
    #remove current user from list
    @concerned_user_list.delete_if {|a| a.user_id == User.current.id}

    render :layout => false
  end

  def edit # spec_me cover_me heckle_me
  end

  def create # spec_me cover_me heckle_me
    @motion = Motion.new(params[:motion])
    @motion.project_id = @project.id
    @motion.author_id = User.current.id
    @motion.params = params[:param]

    respond_to do |format|
      if @motion.concerned_user == User.current
        format.html { redirect_with_flash :error, 'Cannot create a motion concerning yourself', :action => 'index' }
        format.xml  { render :xml => @motion.errors, :status => :unprocessable_entity }
      elsif !@motion.concerned_user && @motion.concerns_someone?
        format.html { redirect_with_flash :error, 'Who does this motion apply to? You need to select the user that this motion is concerned with.', :action => 'index' }
        format.xml  { render :xml => @motion.errors, :status => :unprocessable_entity }
      elsif @motion.save
        format.html { redirect_with_flash :success, 'Motion was successfully created', :action => "show", :id => @motion }
        format.xml  { render :xml => @motion, :status => :created, :location => @motion }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @motion.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update # spec_me cover_me heckle_me
    respond_to do |format|
      if @motion.update_attributes(params[:motion])
        flash.now[:success] = 'Motion was successfully updated.'
        format.html { redirect_to(@motion) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @motion.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy # spec_me cover_me heckle_me
    @motion.destroy

    respond_to do |format|
      format.html { redirect_to(motions_url) }
      format.xml  { head :ok }
    end
  end

  # Reply to a motion discussion
  def reply # spec_me cover_me heckle_me
    @topic = @motion.topic
    @reply = Message.new(params[:reply])
    @reply.author = User.current
    @reply.board = @topic.board
    @topic.children << @reply
    if !@reply.new_record?
      attach_files(@reply, params[:attachments])
    end
    redirect_to :action => 'show', :id => @motion, :project_id => @motion.project_id
  rescue
    404
  end

  private

  def find_project # cover_me heckle_me
    @project = Project.find(params[:project_id]).root
    render_message l(:text_project_locked) if @project.locked?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_motion # cover_me heckle_me
    @motion = Motion.find(params[:id])
    @project = @motion.project
    render_message l(:text_project_locked) if @project.locked?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def check_visibility_permission # cover_me heckle_me
    if !User.current.allowed_to_see_motion?(@motion)
       render_403
       return false
    end
    return true
  end

end
