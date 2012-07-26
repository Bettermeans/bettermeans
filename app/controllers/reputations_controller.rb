class ReputationsController < ApplicationController
  ssl_required :all

  def index
    @reputations = Reputation.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @reputations }
    end
  end

  def show
    @reputation = Reputation.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @reputation }
    end
  end

  def new
    @reputation = Reputation.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @reputation }
    end
  end

  def edit
    @reputation = Reputation.find(params[:id])
  end

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

  def destroy
    @reputation = Reputation.find(params[:id])
    @reputation.destroy

    respond_to do |format|
      format.html { redirect_to(reputations_url) }
      format.xml  { head :ok }
    end
  end
end
