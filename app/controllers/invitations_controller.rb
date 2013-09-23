class InvitationsController < ApplicationController
  before_filter :find_project, :except => :accept
  before_filter :authorize, :except => :accept
  ssl_required :all

  def index # spec_me cover_me heckle_me
    @all_invites, @invitations = paginate :invitations,
                                   :per_page => 30,
                                   :conditions => {:user_id => User.current.id, :project_id => @project.id},
                                   :order => "created_at DESC"

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml  { render :xml => @invitations.to_xml }
      format.json { render :json => @invitation.to_json }
    end
  end

  def show # spec_me cover_me heckle_me
    @invitation = Invitation.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @invitation }
    end
  end

  def new # spec_me cover_me heckle_me
    unless @project.root?
      render_error("Project is not root. No invitations needed here.")
      return
    end

    @note = l(:text_invitation_note_default, {:user => User.current.name, :project => @project.name})

    respond_to do |format|
      format.html
      format.xml  { render :xml => @invitation }
    end
  end

  def edit # spec_me cover_me heckle_me
    @invitation = Invitation.find(params[:id])
  end

  def create # spec_me cover_me heckle_me

    #can't invite someone to anything other than contributor if you're not admin
    if params[:invitation][:role_id] != Role.contributor.id.to_s && !User.current.admin_of?(@project)
      render_403
      return
    end

    success = false
    @emails = params[:emails]
    @email_array = @emails.gsub(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i) {|s| s}.collect
    @email_array.uniq!

    @email_array.each do |email|
        @email_array.delete email unless valid_email?(email)
    end

    @email_array.each do |email|
      @invitation = Invitation.new(params[:invitation])
      @invitation.mail = TMail::Address.parse(email).to_s
      @invitation.project_id = @project.id
      @invitation.user_id = User.current.id
      if @invitation.save
        @invitation.deliver(simple_format_without_paragraph(params[:note]))
        success = true
      end
    end

    respond_to do |format|
      if success
        @emails = nil
        @note = params[:note]
        @roles = Role.find(:all, :conditions => {:level => 1}, :order => "position DESC")

        flash.now[:success] = "#{@email_array.length} invitation(s)  successfully sent to<br>" + @email_array.join(", ")
        format.html { render :action => "new" }
        format.xml  { render :xml => @invitation, :status => :created, :location => @invitation }
      else
        flash.now[:error] = "Failed to send invitations. Make sure emails are properly formatted, and are each on a seperate line"
        format.html { render :action => "new" }
        format.xml  { render :xml => @invitation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def accept # spec_me cover_me heckle_me
    @invitation = Invitation.find(params[:id])

    if @invitation.token != params[:token] || @invitation.status != Invitation::PENDING
      redirect_with_flash :error, l(:error_old_invite), :controller => :projects, :action => :show, :id => @invitation.project_id
      return
    end

    if @invitation.new_mail && !@invitation.new_mail.empty?
      @user = User.find_by_mail(@invitation.new_mail)
    else
      @user = User.find_by_mail(@invitation.mail)
    end

    respond_to do |wants|
      wants.html {
        if @user && !@user.anonymous?
          self.logged_user = @user
          Track.log(Track::LOGIN,request.env['REMOTE_ADDR'])
          @invitation.accept
          msg = "Invitation accepted. You are now a #{@invitation.role.name} of #{@invitation.project.name}."
          redirect_with_flash :success, msg, :controller => :projects, :action => :show, :id => @invitation.project_id
          return
        else
          session[:invitation] = @invitation.token
          redirect_to :controller => :account, :action => :register, :invitation_token => @invitation.token
        end
        }
    end
  end

  def resend # spec_me cover_me heckle_me
    @invitation = Invitation.find(params[:id])

    respond_to do |format|
      if @invitation.resend(params[:note])
        logger.info { "1" }

        format.js do
          logger.info { "format" }

          render :update do |page|
            logger.info { "ID BABY #{@invitation.id}" }
            page.visual_effect :highlight, "row-#{@invitation.id}", :duration => 3
            page.replace "resend-#{@invitation.id}", "Resent!"
            page.call '$.jGrowl', l(:notice_successful_update)
          end
        end
      else
        format.js do
          render :update do |page|
            page.parent.call '$.jGrowl', l(:error_general)
          end
        end
      end
    end
  end

  def destroy # spec_me cover_me heckle_me
    @invitation = Invitation.find(params[:id])
    @invitation.destroy

    respond_to do |format|
      format.js do
        render :update do |page|
          page.visual_effect :highlight, "row-#{@invitation.id}", :duration => 3
          page.remove "row-#{@invitation.id}"
          page.call '$.jGrowl', l(:notice_successful_delete)
        end
      end
    end
  end

  private

  def find_project # cover_me heckle_me
    @project = Project.find(params[:project_id])
    render_message l(:text_project_locked) if @project.locked?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def valid_email?(email) # cover_me heckle_me
    TMail::Address.parse(email)
    return true
  rescue
    return false
  end

end
