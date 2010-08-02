#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# activity_streams_module.rb provides ActivityStreamsModule 
# 
# ActivityStreamsModule is included in your generated ActivityStreams Controller and provides base functionality for the Activity Streams Plug-in
module ActivityStreamsModule
  # GET /activity_streams
  # GET /activity_streams.xml
  def index
    @activity_streams = ActivityStream.find(:all, :limit => 200, :order => "updated_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activity_streams }
    end
  end

  # GET /activity_streams/1
  # GET /activity_streams/1.xml
  def show
    @activity_stream = ActivityStream.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity_stream }
    end
  end

  # GET /activity_streams/new
  # GET /activity_streams/new.xml
  def new
    @activity_stream = ActivityStream.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity_stream }
    end
  end

  # GET /activity_streams/1/edit
  def edit
    @activity_stream = ActivityStream.find(params[:id])
  end

  # POST /activity_streams
  # POST /activity_streams.xml
  def create
    @activity_stream = ActivityStream.new(params[:activity_stream])

    respond_to do |format|
      if @activity_stream.save
        flash[:notice] = 'ActivityStream was successfully created.'
        format.html { redirect_to(@activity_stream) }
        format.xml  { render :xml => @activity_stream, :status => :created, :location => @activity_stream }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity_stream.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /activity_streams/1
  # PUT /activity_streams/1.xml
  def update
    @activity_stream = ActivityStream.find(params[:id])

    respond_to do |format|
      if @activity_stream.update_attributes(params[:activity_stream])
        flash[:notice] = 'ActivityStream was successfully updated.'
        format.html { redirect_to(@activity_stream) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity_stream.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /activity_streams/1
  # DELETE /activity_streams/1.xml
  def destroy 
    @activity_stream = ActivityStream.find(params[:id])

    respond_to do |format|
      if (current_user.admin? || (current_user.id == @activity_stream.actor_id && @activity_stream.actor_type == ACTIVITY_STREAM_USER_MODEL)) && @activity_stream.soft_destroy
        flash[:notice] = 'Activity Removed.'
        format.html { redirect_to "#{request.protocol}#{request.host_with_port}#{params[:ref]}" }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Unexpected Error removing ActivityStream.'
        format.html {redirect_to "#{request.protocol}#{request.host_with_port}#{params[:ref]}"}
        format.xml  { head :error }
      end
    end
  end

  def feed

    klass = Object::const_get(ACTIVITY_STREAM_USER_MODEL)
    @user = klass.find_by_activity_stream_token params[:activity_stream_token] unless params[:activity_stream_token].blank?

    render :nothing => true and return if @user.nil?

    @activity_streams = ActivityStream.recent_actors(@user,:feed_location)
    
    respond_to do |wants|
      wants.atom { render :partial => 'activity_streams/activity_stream_feed.atom.builder' }
    end
  end

end
