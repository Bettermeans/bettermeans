class ReputationsController < ApplicationController
  ssl_required :all
  # GET /reputations
  # GET /reputations.xml
  def index
    @reputations = Reputation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reputations }
    end
  end

  # GET /reputations/1
  # GET /reputations/1.xml
  def show
    @reputation = Reputation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reputation }
    end
  end

  # GET /reputations/new
  # GET /reputations/new.xml
  def new
    @reputation = Reputation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reputation }
    end
  end

  # GET /reputations/1/edit
  def edit
    @reputation = Reputation.find(params[:id])
  end

  # POST /reputations
  # POST /reputations.xml
  def create
    @reputation = Reputation.new(params[:reputation])

    respond_to do |format|
      if @reputation.save
        flash.now[:success] = 'Reputation was successfully created.'
        format.html { redirect_to(@reputation) }
        format.xml  { render :xml => @reputation, :status => :created, :location => @reputation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reputation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reputations/1
  # PUT /reputations/1.xml
  def update
    @reputation = Reputation.find(params[:id])

    respond_to do |format|
      if @reputation.update_attributes(params[:reputation])
        flash.now[:success] = 'Reputation was successfully updated.'
        format.html { redirect_to(@reputation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reputation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reputations/1
  # DELETE /reputations/1.xml
  def destroy
    @reputation = Reputation.find(params[:id])
    @reputation.destroy

    respond_to do |format|
      format.html { redirect_to(reputations_url) }
      format.xml  { head :ok }
    end
  end
end
