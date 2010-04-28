class CreditsController < ApplicationController
  
  before_filter :require_admin
  
  # GET /credits
  # GET /credits.xml
  def index
    @project = Project.find(params[:project_id]) unless params[:project_id].nil?
    @credits = @project.credits
    
    @active_credits = @credits.find_all{|credit| credit.enabled == true }.group_by{|credit| credit.owner_id}
    
    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @credits }
    end
  end

  # GET /credits/1
  # GET /credits/1.xml
  def show
    @credit = Credit.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @credit }
    end
  end

  # GET /credits/new
  # GET /credits/new.xml
  def new
    @credit = Credit.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @credit }
    end
  end

  # GET /credits/1/edit
  def edit
    @credit = Credit.find(params[:id])
  end

  # POST /credits
  # POST /credits.xml
  def create
    @credit = Credit.new(params[:credit])

    respond_to do |format|
      if @credit.save
        flash[:notice] = 'Credit was successfully created.'
        format.html { redirect_to :controller => :projects, :id => @credit.project_id, :action => "credits" }
        format.xml  { render :xml => @credit, :status => :created, :location => @credit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @credit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /credits/1
  # PUT /credits/1.xml
  def update
    @credit = Credit.find(params[:id])

    respond_to do |format|
      if @credit.update_attributes(params[:credit])
        flash[:notice] = 'Credit was successfully updated.'
        format.html { redirect_to :controller => :projects, :id => @credit.project_id, :action => "credits" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @credit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /credits/1
  # DELETE /credits/1.xml
  def destroy
    @credit = Credit.find(params[:id])
    @credit.destroy

    respond_to do |format|
      format.html { redirect_to :controller => :projects, :id => @credit.project_id, :action => "credits" }
      format.xml  { head :ok }
    end
  end
end
