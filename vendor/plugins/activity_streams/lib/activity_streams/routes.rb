#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# routes.rb adds additional routes for ActivityStreamsModule
#
class ActionController::Routing::RouteSet # :nodoc:
  def draw # :nodoc:
    clear! 
    mapper = Mapper.new(self) 

    activity_stream_maps(mapper) 

    yield mapper
		
    install_helpers
  end

  def activity_stream_maps(map) # :nodoc:
    map.your_activities '/feeds/your_activities/:activity_stream_token', :controller => 'activity_streams', :action => 'feed', :format => 'atom'
    map.resources :activity_stream_preferences
    map.resources :activity_streams
  end

end
