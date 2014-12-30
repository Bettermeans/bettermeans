#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file
# LICENSE included with this ActivityStreams plug-in.
#++
# Template to generate the controllers
class ActivityStreamsController < ApplicationController

  before_filter :authorize, :except => [:index]

  def index # heckle_me
    respond_to do |format|
      format.js do
        render :update do |page|
          if params[:refresh]
            page.replace "activity_stream_list", :partial => "activity_streams/activity_stream_list", :locals => {
                                                :user_id => params[:user_id],
                                                :project_id => params[:project_id],
                                                :with_subprojects => params[:with_subprojects],
                                                :limit => params[:limit],
                                                :max_created_at => nil,
                                                :show_refresh => true}
            page.call "arm_fancybox" # attaches fancybox triggers to new issues
            page.call "break_long_words"
          else
            page.replace "activity_stream_bottom", :partial => "activity_streams/activity_stream_list", :locals => {
                                                :user_id => params[:user_id],
                                                :project_id => params[:project_id],
                                                :with_subprojects => params[:with_subprojects],
                                                :limit => params[:limit],
                                                :max_created_at => params[:max_created_at],
                                                :show_refresh => false}
            page.call "arm_fancybox" # attaches fancybox triggers to new issues
            page.call "break_long_words"
          end
        end
      end
    end
  end

  def show # heckle_me
    @activity_stream = ActivityStream.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @activity_stream }
    end
  end

  def new # heckle_me
    @activity_stream = ActivityStream.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @activity_stream }
    end
  end

  def edit # heckle_me
    @activity_stream = ActivityStream.find(params[:id])
  end

  def create # heckle_me
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

  def update # heckle_me
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

  def destroy # heckle_me
    @activity_stream = ActivityStream.find(params[:id])

    respond_to do |format|
      if (current_user.admin? || (current_user.id == @activity_stream.actor_id && @activity_stream.actor_type == ACTIVITY_STREAM_USER_MODEL)) && @activity_stream.soft_destroy
        flash.now[:success] = 'Activity Removed.'
        format.html { redirect_to "#{request.protocol}#{request.host_with_port}#{params[:ref]}" }
        format.xml  { head :ok }
      else
        flash.now[:error] = 'Unexpected Error removing ActivityStream.'
        format.html {redirect_to "#{request.protocol}#{request.host_with_port}#{params[:ref]}"}
        format.xml  { head :unprocessable_entity }
      end
    end
  end

end
