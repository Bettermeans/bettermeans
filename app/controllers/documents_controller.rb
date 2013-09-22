# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class DocumentsController < ApplicationController
  default_search_scope :documents
  before_filter :find_project, :only => [:index, :new]
  before_filter :find_document, :except => [:index, :new]
  before_filter :authorize
  ssl_required :all

  helper :attachments

  log_activity_streams :current_user, :name, :added, :@document, :title, :new, :documents, {:object_description_method => :description}
  log_activity_streams :current_user, :name, :updated, :@document, :title, :edit, :documents, {:object_description_method => :description}
  log_activity_streams :current_user, :name, :deleted, :@document, :title, :destroy, :documents, {:object_description_method => :description}


  def index # spec_me cover_me heckle_me
    @sort_by = %w(catego»ry date title author).include?(params[:sort_by]) ? params[:sort_by] : 'title'
    documents = @project.documents.find :all, :include => [:attachments]
    case @sort_by
    when 'date'
      @grouped = documents.group_by {|d| d.updated_at.to_date }
    when 'title'
      @grouped = documents.group_by {|d| d.title.first.upcase}
    when 'author'
      @grouped = documents.select{|d| d.attachments.any?}.group_by {|d| d.attachments.last.author}
    else
      @grouped = documents.group_by {|d| d.updated_at.to_date }
    end
    @document = @project.documents.build
    render :layout => false if request.xhr?
  end

  def show # spec_me cover_me heckle_me
    @attachments = @document.attachments.find(:all, :order => "created_at DESC")
  end

  def new # spec_me cover_me heckle_me
    @document = @project.documents.build(params[:document])
    if request.post? and @document.save
      attach_files(@document, params[:attachments])
      flash.now[:success] = l(:notice_successful_create)
      redirect_to :action => 'index', :project_id => @project
    end
  end

  def edit # spec_me cover_me heckle_me
    if request.post? and @document.update_attributes(params[:document])
      flash.now[:success] = l(:notice_successful_update)
      redirect_to :action => 'show', :id => @document
    end
  end

  def destroy # spec_me cover_me heckle_me
    @document.destroy
    redirect_to :controller => 'documents', :action => 'index', :project_id => @project
  end

  def add_attachment # spec_me cover_me heckle_me
    attachments = attach_files(@document, params[:attachments])
    Mailer.deliver_attachments_added(attachments) if !attachments.empty? && Setting.notified_events.include?('document_added')
    redirect_to :action => 'show', :id => @document
  end

  private

  def find_project # cover_me heckle_me
    @project = Project.find(params[:project_id])
    render_message l(:text_project_locked) if @project.locked?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_document # cover_me heckle_me
    @document = Document.find(params[:id])
    @project = @document.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
