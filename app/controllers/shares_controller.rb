class SharesController < ApplicationController
  ssl_required :all  
  
  # GET /shares
  # GET /shares.xml
  def index
    @shares = Share.all
    @project = Project.find(params[:project_id]) unless params[:project_id].nil?

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shares }
    end
  end

  # GET /shares/1
  # GET /shares/1.xml
  def show
    @share = Share.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @share }
    end
  end

  # GET /shares/new
  # GET /shares/new.xml
  def new
    @share = Share.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @share }
    end
  end

  # GET /shares/1/edit
  def edit
    @share = Share.find(params[:id])
  end

  # POST /shares
  # POST /shares.xml
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

  # PUT /shares/1
  # PUT /shares/1.xml
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

  # DELETE /shares/1
  # DELETE /shares/1.xml
  def destroy
    @share = Share.find(params[:id])
    @share.destroy

    respond_to do |format|
      format.html { redirect_to(shares_url) }
      format.xml  { head :ok }
    end
  end
end
