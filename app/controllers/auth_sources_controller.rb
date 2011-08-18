# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class AuthSourcesController < ApplicationController
  layout 'admin'
  
  before_filter :require_admin
  ssl_required :all

  def index
    list
    render :action => 'list' unless request.xhr?
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @auth_source_pages, @auth_sources = paginate :auth_sources, :per_page => 10
    render :action => "list", :layout => false if request.xhr?
  end

  def new
    @auth_source = AuthSourceLdap.new
  end

  def create
    @auth_source = AuthSourceLdap.new(params[:auth_source])
    if @auth_source.save
      flash.now[:success] = l(:notice_successful_create)
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @auth_source = AuthSource.find(params[:id])
  end

  def update
    @auth_source = AuthSource.find(params[:id])
    if @auth_source.update_attributes(params[:auth_source])
      flash.now[:success] = l(:notice_successful_update)
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end
  
  def test_connection
    @auth_method = AuthSource.find(params[:id])
    begin
      @auth_method.test_connection
      flash.now[:success] = l(:notice_successful_connection)
    rescue => text
      flash.now[:error] = "Unable to connect (#{text})"
    end
    redirect_to :action => 'list'
  end

  def destroy
    @auth_source = AuthSource.find(params[:id])
    unless @auth_source.users.find(:first)
      @auth_source.destroy
      flash.now[:success] = l(:notice_successful_delete)
    end
    redirect_to :action => 'list'
  end
end
