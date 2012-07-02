class HourlyTypesController < ApplicationController
  before_filter :find_project
  ssl_required :all


  def new
    @hourly_type = HourlyType.new(params[:hourly_type])
    @hourly_type.project = @project
    if request.post? && @hourly_type.save
      flash.now[:success] = l(:notice_successful_create)
      redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'hourly_types'
    end
  end

  def edit
    if request.post? && @hourly_type.update_attributes(params[:hourly_type])
      redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'hourly_types'
    end
  end

  def destroy
    @hourly_type.destroy
    redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'hourly_types'
  end


  private

  def find_project
    @project = Project.find(params[:project_id])
    @hourly_type = @project.hourly_types.find(params[:id]) if params[:id]
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
