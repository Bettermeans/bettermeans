# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license
#

class AttachmentsController < ApplicationController
  before_filter :find_project, :only => [:show, :download, :destroy]
  before_filter :read_authorize, :except => [:create, :destroy]
  before_filter :delete_authorize, :only => [:destroy]
  ssl_required :all

  verify :method => :post, :only => :destroy

  unloadable # Send unloadable so it will not be unloaded in development

  before_filter :redirect_to_s3, :except => [:destroy, :create]


  def create # cover_me heckle_me
    if params[:file]
      file = params[:file]
      a = Attachment.create(:container_id => params[:container_id],
                            :container_type => params[:container_type],
                            :file => file,
                            :author => User.current)
    end

    render :json => a.to_json
  end

  def show # spec_me cover_me heckle_me
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

  def download # spec_me cover_me heckle_me
    if @attachment.container.is_a?(Project)
      @attachment.increment_download
    end

    # images are sent inline
    send_file @attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
                                    :type => @attachment.content_type,
                                    :disposition => (@attachment.image? ? 'inline' : 'attachment')
  end

  def destroy # spec_me cover_me heckle_me
    # Make sure association callbacks are called
    @attachment.container.attachments.delete(@attachment)
    redirect_to :back
  rescue ::ActionController::RedirectBackError
    redirect_to :controller => 'projects', :action => 'show', :id => @project
  end

  private

  def redirect_to_s3 # cover_me heckle_me
    if @attachment.container.is_a?(Project)
      @attachment.increment_download
    end
    redirect_to("#{RedmineS3::Connection.uri}/#{@attachment.disk_filename}")
  end

  def find_project # cover_me heckle_me
    @attachment = Attachment.find(params[:id])
    # Show 404 if the filename in the url is wrong
    raise ActiveRecord::RecordNotFound if params[:filename] && params[:filename] != @attachment.filename
    @project = @attachment.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Checks that the file exists and is readable
  def file_readable # cover_me heckle_me
    @attachment.readable? ? true : render_404
  end

  def read_authorize # cover_me heckle_me
    @attachment.visible? ? true : deny_access
  end

  def delete_authorize # cover_me heckle_me
    @attachment.deletable? ? true : deny_access
  end

  # Returns a string that can be used as filename value in Content-Disposition header
  def filename_for_content_disposition(name) # cover_me heckle_me
    request.env['HTTP_USER_AGENT'] =~ %r{MSIE} ? ERB::Util.url_encode(name) : name
  end

end
