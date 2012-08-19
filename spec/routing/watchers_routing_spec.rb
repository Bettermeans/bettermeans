require 'spec_helper'

describe WatchersController do

  describe "routing" do

    it "routes to #watch" do
      route_for(:controller => "watchers", :action => "watch", :id => '4').should == "/watchers/watch/4"
    end

    it "routes to #unwatch" do
      route_for(:controller => "watchers", :action => "unwatch", :id => '4').should == "/watchers/unwatch/4"
    end

    it "routes to #new" do
      route_for(:controller => "watchers", :action => "new").should == "/watchers/new"
    end

    it "routes to #destroy" do
      route_for(:controller => "watchers", :action => "destroy", :id => '4').should == "/watchers/destroy/4"
    end

  end

end
