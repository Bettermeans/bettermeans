class CreditDistributionsController < ApplicationController
  before_filter :require_admin
  ssl_required :all


  def index
    @credit_distributions = CreditDistribution.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @credit_distributions }
    end
  end

  def show
    @credit_distribution = CreditDistribution.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @credit_distribution }
    end
  end

  def new
    @credit_distribution = CreditDistribution.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @credit_distribution }
    end
  end

  def edit
    @credit_distribution = CreditDistribution.find(params[:id])
  end

  def create
    @credit_distribution = CreditDistribution.new(params[:credit_distribution])

    respond_to do |format|
      if @credit_distribution.save
        flash.now[:success] = 'CreditDistribution was successfully created.'
        format.html { redirect_to(@credit_distribution) }
        format.xml  { render :xml => @credit_distribution, :status => :created, :location => @credit_distribution }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @credit_distribution.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @credit_distribution = CreditDistribution.find(params[:id])

    respond_to do |format|
      if @credit_distribution.update_attributes(params[:credit_distribution])
        flash.now[:success] = 'CreditDistribution was successfully updated.'
        format.html { redirect_to(@credit_distribution) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @credit_distribution.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @credit_distribution = CreditDistribution.find(params[:id])
    @credit_distribution.destroy

    respond_to do |format|
      format.html { redirect_to(credit_distributions_url) }
      format.xml  { head :ok }
    end
  end
end
