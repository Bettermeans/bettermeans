class TeamOffersController < ApplicationController
  # GET /team_offers
  # GET /team_offers.xml
  def index
    @team_offers = TeamOffer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @team_offers }
    end
  end

  # GET /team_offers/1
  # GET /team_offers/1.xml
  def show
    @team_offer = TeamOffer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team_offer }
    end
  end

  # GET /team_offers/new
  # GET /team_offers/new.xml
  def new
    @team_offer = TeamOffer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team_offer }
    end
  end

  # GET /team_offers/1/edit
  def edit
    @team_offer = TeamOffer.find(params[:id])
  end

  # POST /team_offers
  # POST /team_offers.xml
  def create
    @team_offer = TeamOffer.new(params[:team_offer])

    respond_to do |format|
      if @team_offer.save
        flash[:notice] = 'TeamOffer was successfully created.'
        format.html { redirect_to(@team_offer) }
        format.xml  { render :xml => @team_offer, :status => :created, :location => @team_offer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @team_offer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /team_offers/1
  # PUT /team_offers/1.xml
  def update
    @team_offer = TeamOffer.find(params[:id])
    @team_offer.response = params[:response]
    # @team_offer.save
    logger.info(params.inspect)
    
    respond_to do |format|
      if @team_offer.save
        if (!params[:notification_id].nil?)
          Notification.find(params[:notification_id]).mark_as_responded
          render :template => "notifications/hide", :layout => false
          return
        else
          # flash[:notice] = 'TeamOffer was successfully updated.'
          format.html { redirect_to(@team_offer) }
          format.xml  { head :ok }
        end
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @team_offer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /team_offers/1
  # DELETE /team_offers/1.xml
  def destroy
    @team_offer = TeamOffer.find(params[:id])
    @team_offer.destroy

    respond_to do |format|
      format.html { redirect_to(team_offers_url) }
      format.xml  { head :ok }
    end
  end
end
