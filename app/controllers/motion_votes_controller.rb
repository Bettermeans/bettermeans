class MotionVotesController < ApplicationController
  ssl_required :all

  # before_filter :require_admin
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
    @motion_vote.motion_id = params[:motion_id]
    @motion_vote.user_id = User.current.id

    if @motion_vote.motion.motion_type == Motion::TYPE_SHARE
      sum = @motion_vote.user.shares.for_project(@motion_vote.motion.project_id).sum(:amount).to_i
      @motion_vote.points = params[:points].to_i * sum
    else
      @motion_vote.points = params[:points]
    end

    respond_to do |format|
      if @motion_vote.save
        # flash.now[:success] = @motion_vote.isbinding ? 'Your binding vote was cast' : 'Your non-binding vote was cast'
        format.js  { render :action => "cast_vote", :motion => @motion_vote.motion}
      else
        format.js { render :action => "error"}
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
        flash.now[:success] = 'MotionVote was successfully updated.'
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
