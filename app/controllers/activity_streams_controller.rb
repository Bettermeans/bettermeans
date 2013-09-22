#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file
# LICENSE included with this ActivityStreams plug-in.
#++
# Template to generate the controllers
class ActivityStreamsController < ApplicationController

  include ActivityStreamsModule
  before_filter :authorize, :except => [ :index, :feed]
  ssl_required :all

  def index # spec_me cover_me heckle_me
    respond_to do |wants|
      wants.js do
        render :update do |page|
          if params[:refresh]
            page.replace "activity_stream_list", :partial => "activity_streams/activity_stream_list", :locals => {
                                                :user_id => params[:user_id],
                                                :project_id => params[:project_id],
                                                :with_subprojects => params[:with_subprojects],
                                                :limit => params[:limit],
                                                :max_created_at => nil,
                                                :show_refresh => true}
            page.call "arm_fancybox" #attaches fancybox triggers to new issues
            page.call "break_long_words"
          else
            page.replace "activity_stream_bottom", :partial => "activity_streams/activity_stream_list", :locals => {
                                                :user_id => params[:user_id],
                                                :project_id => params[:project_id],
                                                :with_subprojects => params[:with_subprojects],
                                                :limit => params[:limit],
                                                :max_created_at => params[:max_created_at],
                                                :show_refresh => false}
            page.call "arm_fancybox" #attaches fancybox triggers to new issues
            page.call "break_long_words"
          end
        end
      end
    end

  end

end
