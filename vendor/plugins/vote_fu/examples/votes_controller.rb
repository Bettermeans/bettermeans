# An example controller for "votes" that are nested resources under users. See examples/routes.rb

class VotesController < ApplicationController

  # First, figure out our nested scope. User or Voteable? 
  before_filter :find_votes_for_my_scope, :only => [:index]
     
  before_filter :login_required, :only => [:new, :edit, :destroy, :create, :update]
  before_filter :must_own_vote,  :only => [:edit, :destroy, :update]
  before_filter :not_allowed,    :only => [:edit, :update, :new]

  # GET /users/:user_id/votes/
  # GET /users/:user_id/votes.xml
  # GET /users/:user_id/voteables/:voteable_id/votes/
  # GET /users/:user_id/voteables/:voteable_id/votes.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @votes }
    end
  end

  # GET /users/:user_id/votes/1
  # GET /users/:user_id/votes/1.xml
  # GET /users/:user_id/voteables/:voteable_id/votes/1
  # GET /users/:user_id/voteables/:voteable_id/1.xml
  def show
    @voteable = Vote.find(params[:id])

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

  # POST /users/:user_id/voteables/:voteable_id/votes
  # POST /users/:user_id/voteables/:voteable_id/votes.xml
  def create
    @voteable = Voteable.find(params[:quote_id])
    
    respond_to do |format|
      if current_user.vote(@voteable, params[:vote])
        format.rjs  { render :action => "create", :vote => @vote }
        format.html { redirect_to([@voteable.user, @voteable]) }
        format.xml  { render :xml => @voteable, :status => :created, :location => @voteable }
      else
        format.rjs  { render :action => "error" }
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
    if params[:voteable_id]
      @votes = Vote.for_voteable(Voteable.find(params[:voteable_id])).descending
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
        redirect_to user_path(current_user)
      end
    end
  end

end
