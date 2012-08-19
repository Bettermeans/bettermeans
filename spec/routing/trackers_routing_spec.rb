require 'spec_helper'

describe TrackersController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "trackers", :action => "index").should == "/trackers"
    end

    it "routes to #list" do
      route_for(:controller => "trackers", :action => "list", :id => '4').should == "/trackers/list/4"
    end

    it "routes to #new" do
      route_for(:controller => "trackers", :action => "new").should == "/trackers/new"
      route_for(:controller => "trackers", :action => "new").should == { :path => "/trackers/new", :method => :post }
    end

    it "routes to #edit" do
      route_for(:controller => "trackers", :action => "edit", :id => '4').should == "/trackers/edit/4"
      route_for(:controller => "trackers", :action => "edit", :id => '4').should == { :path => "/trackers/edit/4", :method => :post }
    end

    it "routes to #destroy" do
      route_for(:controller => "trackers", :action => "destroy", :id => '4').should == "/trackers/destroy/4"
      route_for(:controller => "trackers", :action => "destroy", :id => '4').should == { :path => "/trackers/destroy/4", :method => :post }
    end

  end

end
