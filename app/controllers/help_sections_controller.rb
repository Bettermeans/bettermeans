class HelpSectionsController < ApplicationController
  before_filter :authorize, :except => :dont_show
  ssl_required :all

  def show # spec_me cover_me heckle_me

    respond_to do |format|
      if @help_section.show
        format.html
        format.xml  { render :xml => @help_section }
      else
        format.html { render :nothing => true}
      end
    end
  end

  def dont_show # spec_me cover_me heckle_me
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

  def new # spec_me cover_me heckle_me
    @help_section = HelpSection.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @help_section }
    end
  end

  def edit # spec_me cover_me heckle_me
    @help_section = HelpSection.find(params[:id])
  end

  def create # spec_me cover_me heckle_me
    @help_section = HelpSection.new(params[:help_section])

    respond_to do |format|
      if @help_section.save
        flash.now[:success] = 'HelpSection was successfully created.'
        format.html { redirect_to(@help_section) }
        format.xml  { render :xml => @help_section, :status => :created, :location => @help_section }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @help_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update # spec_me cover_me heckle_me
    @help_section = HelpSection.find(params[:id])

    respond_to do |format|
      if @help_section.update_attributes(params[:help_section])
        flash.now[:success] = 'HelpSection was successfully updated.'
        format.html { redirect_to(@help_section) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @help_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy # spec_me cover_me heckle_me
    @help_section = HelpSection.find(params[:id])
    @help_section.destroy

    respond_to do |format|
      format.html { redirect_to(help_sections_url) }
      format.xml  { head :ok }
    end
  end
end
