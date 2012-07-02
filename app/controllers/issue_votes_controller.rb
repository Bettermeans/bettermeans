class IssueVotesController < ApplicationController
  ssl_required :all

  # GET /issue_votes
  # GET /issue_votes.xml
  def index
    @issue_votes = IssueVote.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @issue_votes }
    end
  end

  # GET /issue_votes/1
  # GET /issue_votes/1.xml
  def show
    @issue_vote = IssueVote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @issue_vote }
    end
  end

  # GET /issue_votes/new
  # GET /issue_votes/new.xml
  def new
    @issue_vote = IssueVote.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @issue_vote }
    end
  end

  # GET /issue_votes/1/edit
  def edit
    @issue_vote = IssueVote.find(params[:id])
  end

  # POST /issue_votes
  # POST /issue_votes.xml
  def create
    @issue_vote = IssueVote.new(params[:issue_vote])

    respond_to do |format|
      if @issue_vote.save
        flash.now[:success] = 'IssueVote was successfully created.'
        format.html { redirect_to(@issue_vote) }
        format.xml  { render :xml => @issue_vote, :status => :created, :location => @issue_vote }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @issue_vote.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /issue_votes/1
  # PUT /issue_votes/1.xml
  def update
    @issue_vote = IssueVote.find(params[:id])

    respond_to do |format|
      if @issue_vote.update_attributes(params[:issue_vote])
        flash.now[:success] = 'IssueVote was successfully updated.'
        format.html { redirect_to(@issue_vote) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @issue_vote.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /issue_votes/1
  # DELETE /issue_votes/1.xml
  def destroy
    @issue_vote = IssueVote.find(params[:id])
    @issue_vote.destroy

    respond_to do |format|
      format.html { redirect_to(issue_votes_url) }
      format.xml  { head :ok }
    end
  end
end
