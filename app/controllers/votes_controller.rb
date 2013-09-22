# An example controller for "votes" that are nested resources under users. See examples/routes.rb

class VotesController < ApplicationController

  # First, figure out our nested scope. User or issue?
  before_filter :find_votes_for_my_scope, :only => [:index]
  ssl_required :all

  #TODO: figure out the equivalent of login_required in redmine and fix this line
  before_filter :must_own_vote,  :only => [:edit, :destroy, :update]
  before_filter :not_allowed,    :only => [:edit, :update, :new]

  def index # spec_me cover_me heckle_me
    respond_to do |format|
      format.html
      format.xml  { render :xml => @votes }
    end
  end

  def show # spec_me cover_me heckle_me
    @issue = Vote.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @vote }
    end
  end

  def new # spec_me cover_me heckle_me
  end

  def edit # spec_me cover_me heckle_me
  end

  def create # spec_me cover_me heckle_me

    # TODO: Is there a way to cast the model from :voteable_type automatically?
    # Depending on the type of voteable, we dig it up from a different model
    # See Railscast #154 for find_commentable method
    case params[:voteable_type]
    when "issue"
      @voteable = Issue.find(params[:issue_id])
    when "journal"
      @voteable = Journal.find(params[:journal_id])
    when "message"
      @voteable = Message.find(params[:message_id])
    when "reply"
      @voteable = Message.find(params[:reply_id])
    end

    respond_to do |format|
      if User.current.vote(@voteable, params[:vote])
        format.js  { render :action => "create", :vote => @vote, :voteable_type => params[:voteable_type] }
        format.html { redirect_to([@voteable.author, @voteable]) }
        format.xml  { render :xml => @voteable, :status => :created, :location => @voteable }
      else
        format.js  { render :action => "error" }
        format.html { render :action => "new" }
        format.xml  { render :xml => @vote.errors, :status => :unprocessable_entity }
      end
    end

  end

  def update # spec_me cover_me heckle_me
  end

  def destroy # spec_me cover_me heckle_me
    @vote = Vote.find(params[:id])
    @vote.destroy

    respond_to do |format|
      format.html { redirect_to(user_votes_url) }
      format.xml  { head :ok }
    end
  end

  private

  def find_votes_for_my_scope # cover_me heckle_me
    if params[:issue_id]
      @votes = Vote.for_voteable(issue.find(params[:issue_id])).descending
    elsif params[:user_id]
      @votes = Vote.for_voter(User.find(params[:user_id])).descending
    else
      @votes = []
    end
  end

  def must_own_vote # cover_me heckle_me
    @vote ||= Vote.find(params[:id])
    @vote.user == current_user || ownership_violation
  end

  def ownership_violation # cover_me heckle_me
    respond_to do |format|
      flash.now[:error] = 'You cannot edit or delete votes that you do not own!'
      format.html do
        redirect_to user_path(User.current)
      end
    end
  end

end
