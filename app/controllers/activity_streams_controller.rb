#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# Template to generate the controllers
class ActivityStreamsController < ApplicationController
  include ActivityStreamsModule
  # before_filter :require_login, :except => :feed
  before_filter :authorize, :except => [ :index, :feed]
  
  
  def index
    # @activities_by_item = ActivityStream.fetch(params[:user_id], @project, params[:with_subprojects], params[:length], params[:max_created_on])    

    respond_to do |wants|
      wants.js do
        render :update do |page|
          if params[:refresh]
            page.replace "activity_stream_list", :partial => "activity_streams/activity_stream_list", :locals => { 
                                                :user_id => params[:user_id],
                                                :project_id => params[:project_id],
                                                :with_subprojects => params[:with_subprojects],
                                                :limit => params[:limit],
                                                :max_created_on => nil,
                                                :show_refresh => true}
            page.call "arm_fancybox" #attaches fancybox triggers to new issues
          else
            page.replace "activity_stream_bottom", :partial => "activity_streams/activity_stream_list", :locals => { 
                                                :user_id => params[:user_id],
                                                :project_id => params[:project_id],
                                                :with_subprojects => params[:with_subprojects],
                                                :limit => params[:limit],
                                                :max_created_on => params[:max_created_on],
                                                :show_refresh => false}
            page.call "arm_fancybox" #attaches fancybox triggers to new issues
          end
        end
      end
    end
    
  end
  
end
