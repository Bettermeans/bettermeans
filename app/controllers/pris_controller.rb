class PrisController < ApplicationController
  # GET /pris
  # GET /pris.xml
  def index
    @pris = Pri.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pris }
    end
  end

  # GET /pris/1
  # GET /pris/1.xml
  def show
    @pri = Pri.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pri }
    end
  end

  # GET /pris/new
  # GET /pris/new.xml
  def new
    @pri = Pri.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pri }
    end
  end

  # GET /pris/1/edit
  def edit
    @pri = Pri.find(params[:id])
  end

  # POST /pris
  # POST /pris.xml
  def create
    @pri = Pri.new(params[:pri])

    respond_to do |format|
      if @pri.save
        flash[:notice] = 'Pri was successfully created.'
        format.html { redirect_to(@pri) }
        format.xml  { render :xml => @pri, :status => :created, :location => @pri }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pri.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pris/1
  # PUT /pris/1.xml
  def update
    @pri = Pri.find(params[:id])

    respond_to do |format|
      if @pri.update_attributes(params[:pri])
        flash[:notice] = 'Pri was successfully updated.'
        format.html { redirect_to(@pri) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pri.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pris/1
  # DELETE /pris/1.xml
  def destroy
    @pri = Pri.find(params[:id])
    @pri.destroy

    respond_to do |format|
      format.html { redirect_to(pris_url) }
      format.xml  { head :ok }
    end
  end
end
