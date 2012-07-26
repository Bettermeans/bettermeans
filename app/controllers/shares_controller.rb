class SharesController < ApplicationController
  ssl_required :all

  def index
    @shares = Share.all
    @project = Project.find(params[:project_id]) unless params[:project_id].nil?

    respond_to do |format|
      format.html
      format.xml  { render :xml => @shares }
    end
  end

  def show
    @share = Share.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @share }
    end
  end

  def new
    @share = Share.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @share }
    end
  end

  def edit
    @share = Share.find(params[:id])
  end

  def create
    @share = Share.new(params[:share])

    respond_to do |format|
      if @share.save
        flash.now[:success] = 'Share was successfully created.'
        format.html { redirect_to(@share) }
        format.xml  { render :xml => @share, :status => :created, :location => @share }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @share.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @share = Share.find(params[:id])

    respond_to do |format|
      if @share.update_attributes(params[:share])
        flash.now[:success] = 'Share was successfully updated.'
        format.html { redirect_to(@share) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @share.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @share = Share.find(params[:id])
    @share.destroy

    respond_to do |format|
      format.html { redirect_to(shares_url) }
      format.xml  { head :ok }
    end
  end
end
