require 'spec_helper'

describe AdminController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "admin", :action => "index").should == "/admin"
    end

    it "routes to #projects" do
      route_for(:controller => "admin", :action => "projects").should == "/admin/projects"
    end

    it "routes to #plugins" do
      route_for(:controller => "admin", :action => "plugins").should == "/admin/plugins"
    end

    it "routes to #test_email" do
      route_for(:controller => "admin", :action => "test_email").should == "/admin/test_email"
    end

    it "routes to #user_data_dump" do
      route_for(:controller => "admin", :action => "user_data_dump").should == "/admin/user_data_dump"
    end

    it "routes to #info" do
      route_for(:controller => "admin", :action => "info").should == "/admin/info"
    end

    it "routes to #user_stats" do
      route_for(:controller => "admin", :action => "user_stats").should == "/admin/user_stats"
    end

  end

end
