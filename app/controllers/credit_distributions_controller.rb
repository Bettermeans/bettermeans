class CreditDistributionsController < ApplicationController
  # GET /credit_distributions
  # GET /credit_distributions.xml
  before_filter :require_admin
  ssl_required :all  
  
  
  def index
    @credit_distributions = CreditDistribution.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @credit_distributions }
    end
  end

  # GET /credit_distributions/1
  # GET /credit_distributions/1.xml
  def show
    @credit_distribution = CreditDistribution.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @credit_distribution }
    end
  end

  # GET /credit_distributions/new
  # GET /credit_distributions/new.xml
  def new
    @credit_distribution = CreditDistribution.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @credit_distribution }
    end
  end

  # GET /credit_distributions/1/edit
  def edit
    @credit_distribution = CreditDistribution.find(params[:id])
  end

  # POST /credit_distributions
  # POST /credit_distributions.xml
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

  # PUT /credit_distributions/1
  # PUT /credit_distributions/1.xml
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

  # DELETE /credit_distributions/1
  # DELETE /credit_distributions/1.xml
  def destroy
    @credit_distribution = CreditDistribution.find(params[:id])
    @credit_distribution.destroy

    respond_to do |format|
      format.html { redirect_to(credit_distributions_url) }
      format.xml  { head :ok }
    end
  end
end
