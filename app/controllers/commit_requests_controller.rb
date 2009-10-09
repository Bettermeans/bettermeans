class CommitRequestsController < ApplicationController
  # GET /commit_requests
  # GET /commit_requests.xml
  def index
    @commit_requests = CommitRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @commit_requests }
    end
  end

  # GET /commit_requests/1
  # GET /commit_requests/1.xml
  def show
    @commit_request = CommitRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @commit_request }
    end
  end

  # GET /commit_requests/new
  # GET /commit_requests/new.xml
  def new
    @commit_request = CommitRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @commit_request }
    end
  end

  # GET /commit_requests/1/edit
  def edit
    @commit_request = CommitRequest.find(params[:id])
  end

  # POST /commit_requests
  # POST /commit_requests.xml
  def create
    @commit_request = CommitRequest.new(params[:commit_request])
    
    unless params[:user_id].blank?
      @commit_request.user_id = params[:user_id]
    end
    
    unless params[:issue_id].blank?
      @commit_request.issue_id = params[:issue_id]
    end
    
    unless params[:response].blank?
      @commit_request.response = params[:response]
    end   
    
    
    if @commit_request.response == 2 #somebody is taking this issue
      #we set the responder id equal to the author id
      @commit_request.responder_id = @commit_request.user_id
      #Updating issue status to committed if user_id is current user_id (and change response type to 1 for accepted)
      @user = User.find(@commit_request.user_id)
      @issue = Issue.find(@commit_request.issue_id)
      @issue.assigned_to = @user
      @issue.save      
    end


    respond_to do |format|
      if @commit_request.save
        # flash[:notice] = 'Request for commitment was successfully sent.'
        # format.js  { render :action => "create", :commit_request => @commit_request, :user => @commit_request.user_id, :issue => @commit_request.issue_id}        
        format.js  { render :action => "create", :commit_request => @commit_request}        
        format.html { redirect_to(@commit_request) }
        format.xml  { render :xml => @commit_request, :status => :created, :location => @commit_request }
      else
        format.js  { render :action => "error"}        
        format.html { render :action => "new" }
        format.xml  { render :xml => @commit_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /commit_requests/1
  # PUT /commit_requests/1.xml
  def update
    ##BUGBUG Should we be checking permissions AGAIN here? Just in case someone is hacking the url to gain access to tasks?
    @commit_request = CommitRequest.find(params[:id])
    @commit_request.response = params[:response]
    @commit_request.responder_id = params[:responder_id]
    logger.info("RESSPONSE: #{@commit_request.inspect}")
    @commit_request.save
    logger.info("XXXX: #{@project}")
    
    if @commit_request.response == 8 #somebody is releasing this issue
      @issue = Issue.find(@commit_request.issue_id)
      @issue.assigned_to = nil
      @issue.save      
    end    
    
    if @commit_request.response == 6 #somebody is accepting an offer for this issue
      #Updating issue status to committed if user_id is current user_id (and change response type to 1 for accepted)
      @user = User.find(@commit_request.user_id)
      @issue = Issue.find(@commit_request.issue_id)
      @issue.assigned_to = @user
      @issue.save      
    end
    

    respond_to do |format|
      format.js  { render :action => "update", :commit_request => @commit_request, :created_at => @commit_request.created_at, :updated_at => @commit_request.updated_at}        
      # format.html { redirect_to(commit_requests_url) }
      # format.xml  { head :ok }
    end
  end

  # DELETE /commit_requests/1
  # DELETE /commit_requests/1.xml
  def destroy
    @commit_request = CommitRequest.find(params[:id])
    @commit_request.destroy

    respond_to do |format|
      format.js  { render :action => "destroy", :commit_request => @commit_request}        
      # format.html { redirect_to(commit_requests_url) }
      # format.xml  { head :ok }
    end
  end
end
