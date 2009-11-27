class TeamPointsController < ApplicationController
  # GET /team_points
  # GET /team_points.xml
  def index
    @team_points = TeamPoint.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @team_points }
    end
  end

  # GET /team_points/1
  # GET /team_points/1.xml
  def show
    @team_point = TeamPoint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team_point }
    end
  end

  # GET /team_points/new
  # GET /team_points/new.xml
  def new
    @team_point = TeamPoint.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team_point }
    end
  end

  # GET /team_points/1/edit
  def edit
    @team_point = TeamPoint.find(params[:id])
  end

  # POST /team_points
  # POST /team_points.xml
  def create
    @team_point = TeamPoint.new(params[:team_point])

    respond_to do |format|
      if @team_point.save
        flash[:notice] = 'TeamPoint was successfully created.'
        format.html { redirect_to(@team_point) }
        format.xml  { render :xml => @team_point, :status => :created, :location => @team_point }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @team_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /team_points/1
  # PUT /team_points/1.xml
  def update
    @team_point = TeamPoint.find(params[:id])

    respond_to do |format|
      if @team_point.update_attributes(params[:team_point])
        flash[:notice] = 'TeamPoint was successfully updated.'
        format.html { redirect_to(@team_point) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @team_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /team_points/1
  # DELETE /team_points/1.xml
  def destroy
    @team_point = TeamPoint.find(params[:id])
    @team_point.destroy

    respond_to do |format|
      format.html { redirect_to(team_points_url) }
      format.xml  { head :ok }
    end
  end
end
