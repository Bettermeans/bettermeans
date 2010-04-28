class MotionsController < ApplicationController
  
  before_filter :find_project, :only => [:new,:index, :create]
  
  # GET /motions
  # GET /motions.xml
  def index
    @motions = @project.motions.allactive

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @motions }
    end
  end

  # GET /motions/1
  # GET /motions/1.xml
  def show
    @motion = Motion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @motion }
    end
  end

  # GET /motions/new
  # GET /motions/new.xml
  def new
    @motion = Motion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @motion }
    end
  end

  # GET /motions/1/edit
  def edit
    @motion = Motion.find(params[:id])
  end

  # POST /motions
  # POST /motions.xml
  def create
    @motion = Motion.new(params[:motion])
    @motion.project_id = @project.id

    respond_to do |format|
      if @motion.save
        flash[:notice] = 'Motion was successfully created.'
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @motion, :status => :created, :location => @motion }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @motion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /motions/1
  # PUT /motions/1.xml
  def update
    @motion = Motion.find(params[:id])

    respond_to do |format|
      if @motion.update_attributes(params[:motion])
        flash[:notice] = 'Motion was successfully updated.'
        format.html { redirect_to(@motion) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @motion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /motions/1
  # DELETE /motions/1.xml
  def destroy
    @motion = Motion.find(params[:id])
    @motion.destroy

    respond_to do |format|
      format.html { redirect_to(motions_url) }
      format.xml  { head :ok }
    end
  end
  
  def find_project
    @project = Project.find(params[:project_id]).root
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
end
