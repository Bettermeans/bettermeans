class EstimatesController < ApplicationController
  before_filter :find_project, :authorize, :only => [:index, :create, :update, :destroy ]
  
  # GET /estimates
  # GET /estimates.xml
  def index
    @estimates = Estimate.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @estimates }
    end
  end

  # GET /estimates/1
  # GET /estimates/1.xml
  def show
    @estimate = Estimate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @estimate }
    end
  end

  # GET /estimates/new
  # GET /estimates/new.xml
  def new
    @estimate = Estimate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @estimate }
    end
  end

  # GET /estimates/1/edit
  def edit
    @estimate = Estimate.find(params[:id])
  end

  # POST /estimates
  # POST /estimates.xml
  def create
    @estimate = Estimate.new(params[:estimate])
    @estimate.user_id = User.current.id

    respond_to do |format|
      if @estimate.save
        # flash[:notice] = 'Estimate was successfully created.'
        format.html { redirect_to(@estimate) }
        format.xml  { render :xml => @estimate, :status => :created, :location => @estimate }
        format.js {render :json => @estimate.issue.to_dashboard}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /estimates/1
  # PUT /estimates/1.xml
  def update
    @estimate = Estimate.find(params[:id])

    respond_to do |format|
      if @estimate.update_attributes(params[:estimate])
        # flash[:notice] = 'Estimate was successfully updated.'
        format.html { redirect_to(@estimate) }
        format.xml  { head :ok }
        format.js {render :json => @estimate.issue.to_dashboard}
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /estimates/1
  # DELETE /estimates/1.xml
  def destroy
    @estimate = Estimate.find(params[:id])
    @estimate.destroy

    respond_to do |format|
      format.html { redirect_to(estimates_url) }
      format.xml  { head :ok }
    end
  end
  
  def find_project
    logger.info(params.inspect)
    logger.info(params[:estimate].inspect)
    
    @issue = Issue.find(:first, :conditions => {:id => params[:estimate][:issue_id]})
    @project = @issue.project
  end
  
  
end
