require 'spec_helper'

describe ActivityStreamsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "activity_streams", :action => "index").should == "/activity_streams"
    end

    it "routes to #show" do
      route_for(:controller => "activity_streams", :action => "show", :id => "1").should == "/activity_streams/1"
    end

    it "routes to #new" do
      route_for(:controller => "activity_streams", :action => "new").should == "/activity_streams/new"
    end

    it "routes to #edit" do
      route_for(:controller => "activity_streams", :action => "edit", :id => "1").should == "/activity_streams/1/edit"
    end

    it "routes to #create" do
      route_for(:controller => "activity_streams", :action => "create").should == { :path => "/activity_streams", :method => :post }
    end

    it "routes to #update" do
      route_for(:controller => "activity_streams", :action => "update", :id => "1").should == { :path => "/activity_streams/1", :method => :put }
    end

    it "routes to #destroy" do
      route_for(:controller => "activity_streams", :action => "destroy", :id => "1").should == { :path => "/activity_streams/1", :method => :delete }
    end

  end

end
