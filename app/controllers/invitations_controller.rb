class InvitationsController < ApplicationController
  before_filter :find_project, :except => :accept
  before_filter :authorize, :except => :accept  
  ssl_required :all  
  
  
  # GET /invitations
  # GET /invitations.xml
  def index
    @invitations = Invitation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invitations }
    end
  end

  # GET /invitations/1
  # GET /invitations/1.xml
  def show
    @invitation = Invitation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invitation }
    end
  end

  # GET /invitations/new
  # GET /invitations/new.xml
  def new
    unless @project.root?
      render_error("Project is not root. No invitations needed here.") 
      return
    end
    
    @note = l(:text_invitation_note_default)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invitation }
    end
  end

  # GET /invitations/1/edit
  def edit
    @invitation = Invitation.find(params[:id])
  end

  # POST /invitations
  # POST /invitations.xml
  def create
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
    
    # Mailer.invitation_add(@invitation,params[:note])

    respond_to do |format|
      if success
        @emails = nil
        @note = params[:note]
        flash.now[:success] = "#{@email_array.length} invitation(s)  successfully sent to<br>" + @email_array.join(", ")
        format.html { render :action => "new" }
        format.xml  { render :xml => @invitation, :status => :created, :location => @invitation }
      else
        flash.now[:error] = "Failed to send invitations. Make sure emails are porerply formatted, and are each on a seperate line"
        format.html { render :action => "new" }
        format.xml  { render :xml => @invitation.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def accept
    @invitation = Invitation.find(params[:id])
    
    if @invitation.token != params[:token] || @invitation.status != Invitation::PENDING
      redirect_with_flash :error, l(:error_bad_invite), :controller => :projects, :action => :show, :id => @invitation.project_id 
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
          @invitation.accept
          msg = "Invitation accepted. You are now a #{@invitation.role.name} of #{@invitation.project.name}."
          redirect_with_flash :success, msg, :controller => :projects, :action => :show, :id => @invitation.project_id
          return
        else
          #redirect to register, with an invitation token parameter
          session[:invitation] = @invitation.token
          redirect_to :controller => :account, :action => :register, :invitation_token => @invitation.token
        end
        }
    end
  end

  # PUT /invitations/1
  # PUT /invitations/1.xml
  def update
    @invitation = Invitation.find(params[:id])

    respond_to do |format|
      if @invitation.update_attributes(params[:invitation])
        flash[:notice] = 'Invitation was successfully updated.'
        format.html { redirect_to(@invitation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invitation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invitations/1
  # DELETE /invitations/1.xml
  def destroy
    @invitation = Invitation.find(params[:id])
    @invitation.destroy

    respond_to do |format|
      format.html { redirect_to(invitations_url) }
      format.xml  { head :ok }
    end
  end
  
  private
    def find_project
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
    
    def valid_email?(email)
      TMail::Address.parse(email)
      return true
    rescue
      return false
    end
    
  
end
