class ReputationsController < ApplicationController
  ssl_required :all

  def index # heckle_me
    @reputations = Reputation.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @reputations }
    end
  end

  def show # heckle_me
    @reputation = Reputation.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @reputation }
    end
  end

  def new # heckle_me
    @reputation = Reputation.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @reputation }
    end
  end

  def edit # heckle_me
    @reputation = Reputation.find(params[:id])
  end

  def create # heckle_me
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

  def update # heckle_me
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

  def destroy # heckle_me
    @reputation = Reputation.find(params[:id])
    @reputation.destroy

    respond_to do |format|
      format.html { redirect_to(reputations_url) }
      format.xml  { head :ok }
    end
  end
end
