#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file
# LICENSE included with this ActivityStreams plug-in.
#++
# activity_streams_module.rb provides ActivityStreamsModule
#
# ActivityStreamsModule is included in your generated ActivityStreams Controller and provides base functionality for the Activity Streams Plug-in
module ActivityStreamsModule

  def index # spec_me cover_me heckle_me
    @activity_streams = ActivityStream.find(:all, :limit => 200, :order => "updated_at DESC")

    respond_to do |format|
      format.html
      format.xml  { render :xml => @activity_streams }
    end
  end

  def show # spec_me cover_me heckle_me
    @activity_stream = ActivityStream.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @activity_stream }
    end
  end

  def new # spec_me cover_me heckle_me
    @activity_stream = ActivityStream.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @activity_stream }
    end
  end

  def edit # spec_me cover_me heckle_me
    @activity_stream = ActivityStream.find(params[:id])
  end

  def create # spec_me cover_me heckle_me
    @activity_stream = ActivityStream.new(params[:activity_stream])

    respond_to do |format|
      if @activity_stream.save
        flash.now[:success] = 'ActivityStream was successfully created.'
        format.html { redirect_to(@activity_stream) }
        format.xml  { render :xml => @activity_stream, :status => :created, :location => @activity_stream }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity_stream.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update # spec_me cover_me heckle_me
    @activity_stream = ActivityStream.find(params[:id])

    respond_to do |format|
      if @activity_stream.update_attributes(params[:activity_stream])
        flash.now[:success] = 'ActivityStream was successfully updated.'
        format.html { redirect_to(@activity_stream) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity_stream.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy # spec_me cover_me heckle_me
    @activity_stream = ActivityStream.find(params[:id])

    respond_to do |format|
      if (current_user.admin? || (current_user.id == @activity_stream.actor_id && @activity_stream.actor_type == ACTIVITY_STREAM_USER_MODEL)) && @activity_stream.soft_destroy
        flash.now[:success] = 'Activity Removed.'
        format.html { redirect_to "#{request.protocol}#{request.host_with_port}#{params[:ref]}" }
        format.xml  { head :ok }
      else
        flash.now[:error] = 'Unexpected Error removing ActivityStream.'
        format.html {redirect_to "#{request.protocol}#{request.host_with_port}#{params[:ref]}"}
        format.xml  { head :error }
      end
    end
  end

end
