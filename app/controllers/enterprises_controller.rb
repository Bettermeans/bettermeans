class EnterprisesController < ApplicationController
  ssl_required :all

  def index
    @enterprises = Enterprise.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @enterprises }
    end
  end

  def show
    @enterprise = Enterprise.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @enterprise }
    end
  end

  def new
    @enterprise = Enterprise.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @enterprise }
    end
  end

  def edit
    @enterprise = Enterprise.find(params[:id])
  end

  def create
    @enterprise = Enterprise.new(params[:enterprise])

    respond_to do |format|
      if @enterprise.save
        flash.now[:success] = 'Enterprise was successfully created.'
        format.html { redirect_to(@enterprise) }
        format.xml  { render :xml => @enterprise, :status => :created, :location => @enterprise }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @enterprise.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @enterprise = Enterprise.find(params[:id])

    respond_to do |format|
      if @enterprise.update_attributes(params[:enterprise])
        flash.now[:success] = 'Enterprise was successfully updated.'
        format.html { redirect_to(@enterprise) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @enterprise.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @enterprise = Enterprise.find(params[:id])
    @enterprise.destroy

    respond_to do |format|
      format.html { redirect_to(enterprises_url) }
      format.xml  { head :ok }
    end
  end
end
