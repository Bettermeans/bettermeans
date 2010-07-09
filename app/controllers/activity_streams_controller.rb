#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# Template to generate the controllers
class ActivityStreamsController < ApplicationController
  include ActivityStreamsModule
  before_filter :require_login, :except => :feed
  # before_filter :require_admin, :except => :feed
  
  def index
    @grouped_by_item = ActivityStream.all.group_by {|a| a.object_type + a.object_id.to_s}
    @grouped_by_item.each_pair do |key,value| 
      @grouped_by_item[key] = value.sort_by{|i| - i[:updated_at].to_i}
    end
    
    @grouped_by_item = @grouped_by_item.sort_by{|g| - g[1][0][:updated_at].to_i}
  end
end
