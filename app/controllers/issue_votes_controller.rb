class IssueVotesController < ApplicationController
  ssl_required :all

  def index
    @issue_votes = IssueVote.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @issue_votes }
    end
  end

  def show
    @issue_vote = IssueVote.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @issue_vote }
    end
  end

  def new
    @issue_vote = IssueVote.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @issue_vote }
    end
  end

  def edit
    @issue_vote = IssueVote.find(params[:id])
  end

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

  def destroy
    @issue_vote = IssueVote.find(params[:id])
    @issue_vote.destroy

    respond_to do |format|
      format.html { redirect_to(issue_votes_url) }
      format.xml  { head :ok }
    end
  end
end
