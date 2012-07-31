require 'spec_helper'

describe ActivityStreamPreferencesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "activity_stream_preferences", :action => "index").should == "/activity_stream_preferences"
    end

  end

end
