# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class RolesController < ApplicationController
  layout 'admin'

  before_filter :require_admin
  ssl_required :all

  verify :method => :post, :only => [ :destroy, :move ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list' unless request.xhr?
  end

  def list
    @role_pages, @roles = paginate :roles, :per_page => 25, :order => 'builtin, position'
    render :action => "list", :layout => false if request.xhr?
  end

  def new
    # Prefills the form with 'Non member' role permissions
    @role = Role.new(params[:role] || {:permissions => Role.non_member.permissions})
    if request.post? && @role.save
      # workflow copy
      if !params[:copy_workflow_from].blank? && (copy_from = Role.find_by_id(params[:copy_workflow_from]))
        @role.workflows.copy(copy_from)
      end
      flash.now[:success] = l(:notice_successful_create)
      redirect_to :action => 'index'
    end
    @permissions = @role.setable_permissions
    @roles = Role.find :all, :order => 'builtin, position'
  end

  def edit
    @role = Role.find(params[:id])
    if request.post? and @role.update_attributes(params[:role])
      flash.now[:success] = l(:notice_successful_update)
      redirect_to :action => 'index'
    end
    @permissions = @role.setable_permissions
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    redirect_to :action => 'index'
  rescue
    flash.now[:error] = 'This role is in use and can not be deleted.'
    redirect_to :action => 'index'
  end

  def report
    @roles = Role.find(:all, :order => 'builtin, position')
    @permissions = Redmine::AccessControl.permissions.select { |p| !p.public? }
    if request.post?
      @roles.each do |role|
        role.permissions = params[:permissions][role.id.to_s]
        role.save
      end
      flash.now[:success] = l(:notice_successful_update)
      redirect_to :action => 'index'
    end
  end
end
