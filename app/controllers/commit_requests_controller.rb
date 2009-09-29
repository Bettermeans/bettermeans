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
    
    #TODO: Add logic for updating issue status to committed if user_id is current user_id (and change response type to 1 for accepted)
    

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
    @commit_request = CommitRequest.find(params[:id])

    respond_to do |format|
      if @commit_request.update_attributes(params[:commit_request])
        flash[:notice] = 'CommitRequest was successfully updated.'
        format.html { redirect_to(@commit_request) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @commit_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /commit_requests/1
  # DELETE /commit_requests/1.xml
  def destroy
    @commit_request = CommitRequest.find(params[:id])
    @commit_request.destroy

    logger.info("XXXXXXXXXXXXX" + String(@commit_request.issue_id))
    respond_to do |format|
      format.js  { render :action => "destroy", :commit_request => @commit_request}        
      logger.info("should we be here?")
      # format.html { redirect_to(commit_requests_url) }
      # format.xml  { head :ok }
    end
  end
end
