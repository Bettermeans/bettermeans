# An example controller for "votes" that are nested resources under users. See examples/routes.rb

class VotesController < ApplicationController

  # First, figure out our nested scope. User or issue? 
  before_filter :find_votes_for_my_scope, :only => [:index]
     
  #TODO: figure out the equivalent of login_required in redmine and fix this line   
  #before_filter :login_required, :only => [:new, :edit, :destroy, :create, :update]
  before_filter :must_own_vote,  :only => [:edit, :destroy, :update]
  before_filter :not_allowed,    :only => [:edit, :update, :new]

  # GET /users/:user_id/votes/
  # GET /users/:user_id/votes.xml
  # GET /users/:user_id/issues/:issue_id/votes/
  # GET /users/:user_id/issues/:issue_id/votes.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @votes }
    end
  end

  # GET /users/:user_id/votes/1
  # GET /users/:user_id/votes/1.xml
  # GET /users/:user_id/issues/:issue_id/votes/1
  # GET /users/:user_id/issues/:issue_id/1.xml
  def show
    @issue = Vote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @vote }
    end
  end

  # GET /users/:id/votes/new      
  # GET /users/:id/votes/new.xml  
  # GET /users/:id/votes/new      
  # GET /users/:id/votes/new.xml  
  def new
    # Not generally used. Most people want to vote via AJAX calls.
  end

  # GET /users/:id/votes/1/edit
  def edit
    # Not generally used. Most people don't want to allow editing of votes.
  end

  # POST /users/:user_id/issues/:issue_id/votes
  # POST /users/:user_id/issues/:issue_id/votes.xml
  def create

    #TODO: Is there a way to cast the model from :voteable_type automatically?
    #Depending on the type of voteable, we dig it up from a different model 
    case params[:voteable_type]
      when "issue"    
        @voteable = Issue.find(params[:issue_id])      
      when "journal"
        @voteable = Journal.find(params[:journal_id])      
      when "message"
        @voteable = Message.find(params[:message_id])      
      # when "reply"
      #         @reply = Message.find(params[:reply_id])      
      end
    
    
    respond_to do |format|
      if User.current.vote(@voteable, params[:vote])      
        # flash[:notice] = 'Vote was successfully saved.'        
        format.js  { render :action => "create", :vote => @vote, :voteable_type => params[:voteable_type] }
        format.html { redirect_to([@voteable.author, @voteable]) }
        format.xml  { render :xml => @voteable, :status => :created, :location => @voteable }
      else
        # flash[:notice] = 'Error saving vote'        
        format.js  { render :action => "error" }
        format.html { render :action => "new" }
        format.xml  { render :xml => @vote.errors, :status => :unprocessable_entity }
      end
    end
    
  end

  # PUT /users/:id/votes/1
  # PUT /users/:id/votes/1.xml
  def update
    # Not generally used
  end
  
  # DELETE /users/:id/votes/1
  # DELETE /users/:id/votes/1.xml
  def destroy
    @vote = Vote.find(params[:id])
    @vote.destroy

    respond_to do |format|
      format.html { redirect_to(user_votes_url) }
      format.xml  { head :ok }
    end
  end

  private
  def find_votes_for_my_scope
    if params[:issue_id]
      @votes = Vote.for_voteable(issue.find(params[:issue_id])).descending
    elsif params[:user_id]
      @votes = Vote.for_voter(User.find(params[:user_id])).descending         
    else  
      @votes = []
    end
  end

  def must_own_vote
    @vote ||= Vote.find(params[:id])
    @vote.user == current_user || ownership_violation
  end

  def ownership_violation
    respond_to do |format|
      flash[:notice] = 'You cannot edit or delete votes that you do not own!'
      format.html do
        redirect_to user_path(User.current)
      end
    end
  end

end
