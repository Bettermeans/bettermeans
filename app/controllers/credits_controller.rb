class CreditsController < ApplicationController

  before_filter :require_admin, :except => [:disable, :enable]
  before_filter :find_credit, :only => [:disable, :enable]
  before_filter :self_authorize, :only => [:disable, :enable]
  ssl_required :all


  def index # spec_me cover_me heckle_me
    @project = Project.find(params[:project_id]) unless params[:project_id].nil?

    @credits = @project.credits
    @active_credits = @credits.find_all{|credit| credit.enabled == true }.group_by{|credit| credit.owner_id}



    respond_to do |format|
      format.html
      format.xml  { render :xml => @credits }
    end
  end

  def show # spec_me cover_me heckle_me
    @credit = Credit.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @credit }
    end
  end

  def new # spec_me cover_me heckle_me
    @credit = Credit.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @credit }
    end
  end

  def edit # spec_me cover_me heckle_me
    @credit = Credit.find(params[:id])
  end

  def create # spec_me cover_me heckle_me
    @credit = Credit.new(params[:credit])

    respond_to do |format|
      if @credit.save
        flash.now[:success] = 'Credit was successfully created.'
        format.html { redirect_to :controller => :projects, :id => @credit.project_id, :action => "credits" }
        format.xml  { render :xml => @credit, :status => :created, :location => @credit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @credit.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update # spec_me cover_me heckle_me
    @credit = Credit.find(params[:id])

    respond_to do |format|
      if @credit.update_attributes(params[:credit])
        flash.now[:success] = 'Credit was successfully updated.'
        format.html { redirect_to :controller => :projects, :id => @credit.project_id, :action => "credits" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @credit.errors, :status => :unprocessable_entity }
      end
    end
  end

  def disable # spec_me cover_me heckle_me
    respond_to do |format|
      if @credit.disable
        format.html { redirect_to :controller => :projects, :id => @credit.project_id, :action => "credits" }
        format.js do
          update_credit_partials
        end
      else
        format.html { redirect_to :controller => :projects, :id => @credit.project_id, :action => "credits" }
        format.js do
          render :update do |page|
            page.call '$.jGrowl', 'Something went wrong. Couldn\'t update record.'
          end
        end
      end
    end
  end

  def enable # spec_me cover_me heckle_me
    respond_to do |format|
      if @credit.enable
        format.html { redirect_to :controller => :projects, :id => @credit.project_id, :action => "credits" }
        format.js do
          update_credit_partials
        end
      else
        format.html { redirect_to :controller => :projects, :id => @credit.project_id, :action => "credits" }
        format.js do
          render :update do |page|
            page.call '$.jGrowl', 'Something went wrong. Couldn\'t update record.'
          end
        end
      end
    end
  end

  def update_credit_partials # spec_me cover_me heckle_me
    @project = Project.find(params[:project_id])
    @credits = @project.fetch_credits(params[:with_subprojects])
    @active_credits = @credits.find_all{|credit| credit.enabled == true && credit.settled_on.nil? == true }.group_by{|credit| credit.owner_id}

    render :update do |page|
      page.replace_html "my_credits_partial", :partial => 'credits/my_credits'
      page.replace_html "credit_queue_partial", :partial => 'credits/credit_queue'
      page.replace_html "credit_history_partial", :partial => 'credits/credit_history'
      page.replace_html "active_credits_partial", :partial => 'credits/credit_breakdown', :locals => {:group_credits => @active_credits, :title => l(:label_active_credits)}
      page.visual_effect :highlight, "q_#{@credit.id}", :duration => 2
      page.visual_effect :highlight, "h_#{@credit.id}", :duration => 2
      page.visual_effect :highlight, "m_#{@credit.id}", :duration => 3
    end
  end

  def destroy # spec_me cover_me heckle_me
    @credit = Credit.find(params[:id])
    @credit.destroy

    respond_to do |format|
      format.html { redirect_to :controller => :projects, :id => @credit.project_id, :action => "credits" }
      format.xml  { head :ok }
    end
  end

  private

  def find_credit # cover_me heckle_me
    @credit = Credit.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def self_authorize # cover_me heckle_me
    if User.current.id != @credit.owner_id
      render_403
      return false
    end
  end
end
