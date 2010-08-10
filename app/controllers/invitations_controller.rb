class InvitationsController < ApplicationController
  before_filter :find_project, :except => :accept
  before_filter :authorize, :except => :accept  
  
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
    @email_array = @emails.gsub(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).collect
    @email_array.uniq!
    
    @email_array.each do |email|
      @invitation = Invitation.new(params[:invitation])
      @invitation.mail = email
      @invitation.project_id = @project.id
      @invitation.user_id = User.current.id
      if @invitation.save
        @invitation.send_later(:deliver, params[:notes])
        success = true
      end
    end
    
    
    
    # Mailer.invitation_add(@invitation,params[:note])

    respond_to do |format|
      if success
        @emails = nil
        @note = params[:note]
        flash.now[:notice] = "#{@email_array.count} invitation(s)  successfully sent to<br>" + @email_array.join(", ")
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
      redirect_with_flash :error, "Old or bad invitation", :controller => :projects, :action => :show, :id => @invitation.project_id 
      return
    end

    @user = User.find_by_mail(@invitation.mail)
    respond_to do |wants|
      wants.html {  
        if @user
          self.logged_user = @user
          @invitation.accept
          msg = "Invitation accepted. You are now a #{@invitation.role.name} of #{@invitation.project.name}."
          logger.info { "accepted invitation" }
          redirect_with_flash :success, msg, :controller => :projects, :action => :show, :id => @invitation.project_id
          logger.info { "whats going on?" }
          return
        else
          #redirect to register, with an invitation token parameter
          redirect_with_flash :notice, "Sign up to activate your inviation", :controller => :account, :action => :register, :invitation_token => @invitation.token
          return
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
  
end
