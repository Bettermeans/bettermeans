# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

class SysController < ActionController::Base
  before_filter :check_enabled
  
  def projects
    p = Project.active.has_module(:repository).find(:all, :include => :repository, :order => 'identifier')
    render :xml => p.to_xml(:include => :repository)
  end
  
  def create_project_repository
    project = Project.find(params[:id])
    if project.repository
      render :nothing => true, :status => 409
    else
      logger.info "Repository for #{project.name} was reported to be created by #{request.remote_ip}."
      project.repository = Repository.factory(params[:vendor], params[:repository])
      if project.repository && project.repository.save
        render :xml => project.repository, :status => 201
      else
        render :nothing => true, :status => 422
      end
    end
  end

  protected

  def check_enabled
    User.current = nil
    unless Setting.sys_api_enabled?
      render :nothing => 'Access denied. Repository management WS is disabled.', :status => 403
      return false
    end
  end
end
