require 'spec_helper'

describe NotificationsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "notifications", :action => "index", :id => '5').should == "/notifications/index/5"
    end

    it "routes to #show" do
      route_for(:controller => "notifications", :action => "show", :id => '5').should == "/notifications/show/5"
    end

    it "routes to #new" do
      route_for(:controller => "notifications", :action => "new", :id => '5').should == "/notifications/new/5"
    end

    it "routes to #edit" do
      route_for(:controller => "notifications", :action => "edit", :id => '5').should == "/notifications/edit/5"
    end

    it "routes to #create" do
      route_for(:controller => "notifications", :action => "create", :id => '5').should == "/notifications/create/5"
    end

    it "routes to #update" do
      route_for(:controller => "notifications", :action => "update", :id => '5').should == "/notifications/update/5"
    end

    it "routes to #hide" do
      route_for(:controller => "notifications", :action => "hide", :id => '5').should == "/notifications/hide/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "notifications", :action => "destroy", :id => '5').should == "/notifications/destroy/5"
    end

  end

end
