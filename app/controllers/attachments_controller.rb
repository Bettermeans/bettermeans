# Redmine - project management software
# Copyright (C) 2006-2008  Shereef Bishay
#

class AttachmentsController < ApplicationController
  before_filter :find_project, :except => :create
  before_filter :read_authorize, :except => [:destroy, :create]
  before_filter :delete_authorize, :only => :destroy
  ssl_required :all
  
  verify :method => :post, :only => :destroy
  
  unloadable # Send unloadable so it will not be unloaded in development
  
  before_filter :redirect_to_s3, :except => [:destroy, :create]
  
  
  def create
    logger.info { "params #{params.inspect}" }
    if params[:file]
      file = params[:file]
      logger.info { "file #{file.inspect}" }
      # next unless file && file.size > 0
      a = Attachment.create(:container_id => params[:container_id],
                            :container_type => params[:container_type],
                            :file => file,
                            # :description => attachment['description'].to_s.strip,
                            :author => User.current)
      logger.info { "created attachment #{a.inspect}" }
    end
    logger.info {"done with create" }
    
    render :json => a.to_json
  end
  
  def redirect_to_s3
    if @attachment.container.is_a?(Project)
      @attachment.increment_download
    end
    redirect_to("#{RedmineS3::Connection.uri}/#{@attachment.disk_filename}")
  end
  
  
  def show
    if @attachment.is_diff?
      @diff = File.new(@attachment.diskfile, "rb").read
      render :action => 'diff'
    elsif @attachment.is_text? && @attachment.filesize <= Setting.file_max_size_displayed.to_i.kilobyte
      @content = File.new(@attachment.diskfile, "rb").read
      render :action => 'file'
    else
      download
    end
  end
  
  def download
    if @attachment.container.is_a?(Project)
      @attachment.increment_download
    end
    
    # images are sent inline
    send_file @attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
                                    :type => @attachment.content_type, 
                                    :disposition => (@attachment.image? ? 'inline' : 'attachment')
   
  end
  
  def destroy
    # Make sure association callbacks are called
    @attachment.container.attachments.delete(@attachment)
    redirect_to :back
  rescue ::ActionController::RedirectBackError
    redirect_to :controller => 'projects', :action => 'show', :id => @project
  end
  
private
  def find_project
    @attachment = Attachment.find(params[:id])
    # Show 404 if the filename in the url is wrong
    raise ActiveRecord::RecordNotFound if params[:filename] && params[:filename] != @attachment.filename
    @project = @attachment.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  # Checks that the file exists and is readable
  def file_readable
    @attachment.readable? ? true : render_404
  end
  
  def read_authorize
    @attachment.visible? ? true : deny_access
  end
  
  def delete_authorize
    @attachment.deletable? ? true : deny_access
  end
end
