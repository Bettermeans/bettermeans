class MotionVotesController < ApplicationController
  # GET /motion_votes
  # GET /motion_votes.xml
  def index
    @motion_votes = MotionVote.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @motion_votes }
    end
  end

  # GET /motion_votes/1
  # GET /motion_votes/1.xml
  def show
    @motion_vote = MotionVote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @motion_vote }
    end
  end

  # GET /motion_votes/new
  # GET /motion_votes/new.xml
  def new
    @motion_vote = MotionVote.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @motion_vote }
    end
  end

  # GET /motion_votes/1/edit
  def edit
    @motion_vote = MotionVote.find(params[:id])
  end

  # POST /motion_votes
  # POST /motion_votes.xml
  def create
    @motion_vote = MotionVote.new(params[:motion_vote])

    respond_to do |format|
      if @motion_vote.save
        flash[:notice] = 'MotionVote was successfully created.'
        format.html { redirect_to(@motion_vote) }
        format.xml  { render :xml => @motion_vote, :status => :created, :location => @motion_vote }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @motion_vote.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /motion_votes/1
  # PUT /motion_votes/1.xml
  def update
    @motion_vote = MotionVote.find(params[:id])

    respond_to do |format|
      if @motion_vote.update_attributes(params[:motion_vote])
        flash[:notice] = 'MotionVote was successfully updated.'
        format.html { redirect_to(@motion_vote) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @motion_vote.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /motion_votes/1
  # DELETE /motion_votes/1.xml
  def destroy
    @motion_vote = MotionVote.find(params[:id])
    @motion_vote.destroy

    respond_to do |format|
      format.html { redirect_to(motion_votes_url) }
      format.xml  { head :ok }
    end
  end
end
