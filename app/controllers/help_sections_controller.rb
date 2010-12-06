class HelpSectionsController < ApplicationController
  before_filter :authorize, :except => :dont_show
  ssl_required :all  
  
  # GET /help_sections/1
  # GET /help_sections/1.xml
  def show

    respond_to do |format|
      if @help_section.show
        format.html # show.html.erb
        format.xml  { render :xml => @help_section }
      else
        format.html { render :nothing => true}
      end
    end
  end
  
  def dont_show
    @help_section = HelpSection.find(params[:id])
    @help_section.show = false
    @help_section.save
    respond_to do |wants|
      wants.js { render :update do |page|
                    page.replace "help_section", ""
                  end
          }
    end
  end

  # GET /help_sections/new
  # GET /help_sections/new.xml
  def new
    @help_section = HelpSection.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @help_section }
    end
  end

  # GET /help_sections/1/edit
  def edit
    @help_section = HelpSection.find(params[:id])
  end

  # POST /help_sections
  # POST /help_sections.xml
  def create
    @help_section = HelpSection.new(params[:help_section])

    respond_to do |format|
      if @help_section.save
        flash.now[:notice] = 'HelpSection was successfully created.'
        format.html { redirect_to(@help_section) }
        format.xml  { render :xml => @help_section, :status => :created, :location => @help_section }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @help_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /help_sections/1
  # PUT /help_sections/1.xml
  def update
    @help_section = HelpSection.find(params[:id])

    respond_to do |format|
      if @help_section.update_attributes(params[:help_section])
        flash.now[:notice] = 'HelpSection was successfully updated.'
        format.html { redirect_to(@help_section) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @help_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /help_sections/1
  # DELETE /help_sections/1.xml
  def destroy
    @help_section = HelpSection.find(params[:id])
    @help_section.destroy

    respond_to do |format|
      format.html { redirect_to(help_sections_url) }
      format.xml  { head :ok }
    end
  end
end
