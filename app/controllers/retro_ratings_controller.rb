class RetroRatingsController < ApplicationController
  ssl_required :all

  # before_filter :authorize
  # GET /retro_ratings
  # GET /retro_ratings.xml
  def index
    @retro_ratings = RetroRating.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @retro_ratings }
    end
  end

  # GET /retro_ratings/1
  # GET /retro_ratings/1.xml
  def show
    @retro_rating = RetroRating.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retro_rating }
    end
  end

  # GET /retro_ratings/new
  # GET /retro_ratings/new.xml
  def new
    @retro_rating = RetroRating.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @retro_rating }
    end
  end

  # GET /retro_ratings/1/edit
  def edit
    @retro_rating = RetroRating.find(params[:id])
  end

  # POST /retro_ratings
  # POST /retro_ratings.xml
  def create
    @retro_ratings = params[:retro_ratings].values.collect { |retro_rating| RetroRating.new(retro_rating) }

    #Archive notification for this retrospective
    @retro_id = params[:retro_ratings].values[0]["retro_id"]
    @rater_id = params[:retro_ratings].values[0]["rater_id"]
    Notification.update_all "state = #{Notification::STATE_ARCHIVED}" , ["variation = 'retro_started' AND source_id = ? AND recipient_id = ?", @retro_id, @rater_id]


    #TODO: security: make sure to only create ratings if current user is same as rater_id (and user is actually on those teams!)
    respond_to do |format|
      if @retro_ratings.all?(&:valid?)
        RetroRating.delete_all(:rater_id => @retro_ratings[0].rater_id , :retro_id => @retro_ratings[0].retro_id)
        @retro_ratings.each(&:save!)
        format.html { redirect_to(@retro_rating) }
        format.xml  { render :xml => @retro_rating, :status => :created, :location => @retro_rating }
        format.js  { render :json => @retro_ratings.to_json}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @retro_rating.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /retro_ratings/1
  # PUT /retro_ratings/1.xml
  def update
    @retro_rating = RetroRating.find(params[:id])

    respond_to do |format|
      if @retro_rating.update_attributes(params[:retro_rating])
        flash.now[:success] = 'RetroRating was successfully updated.'
        format.html { redirect_to(@retro_rating) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @retro_rating.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /retro_ratings/1
  # DELETE /retro_ratings/1.xml
  def destroy
    @retro_rating = RetroRating.find(params[:id])
    @retro_rating.destroy

    respond_to do |format|
      format.html { redirect_to(retro_ratings_url) }
      format.xml  { head :ok }
    end
  end

end
