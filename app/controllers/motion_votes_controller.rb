class MotionVotesController < ApplicationController
  ssl_required :all

  def index # spec_me cover_me heckle_me
    @motion_votes = MotionVote.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @motion_votes }
    end
  end

  def show # spec_me cover_me heckle_me
    @motion_vote = MotionVote.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @motion_vote }
    end
  end

  def new # spec_me cover_me heckle_me
    @motion_vote = MotionVote.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @motion_vote }
    end
  end

  def edit # spec_me cover_me heckle_me
    @motion_vote = MotionVote.find(params[:id])
  end

  def create # spec_me cover_me heckle_me
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
        format.js  { render :action => "cast_vote", :motion => @motion_vote.motion}
      else
        format.js { render :action => "error"}
        format.html { render :action => "new" }
        format.xml  { render :xml => @motion_vote.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update # spec_me cover_me heckle_me
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

  def destroy # spec_me cover_me heckle_me
    @motion_vote = MotionVote.find(params[:id])
    @motion_vote.destroy

    respond_to do |format|
      format.html { redirect_to(motion_votes_url) }
      format.xml  { head :ok }
    end
  end
end
