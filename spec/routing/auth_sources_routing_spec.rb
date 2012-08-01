require 'spec_helper'

describe AuthSourcesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "auth_sources", :action => "index").should == "/auth_sources"
    end

    it "routes to #list" do
      route_for(:controller => "auth_sources", :action => "list").should == "/auth_sources/list"
    end

    it "routes to #new" do
      route_for(:controller => "auth_sources", :action => "new").should == "/auth_sources/new"
    end

    it "routes to #create" do
      route_for(:controller => "auth_sources", :action => "create").should == "/auth_sources/create"
    end

    it "routes to #edit" do
      route_for(:controller => "auth_sources", :action => "edit").should == "/auth_sources/edit"
    end

    it "routes to #update" do
      route_for(:controller => "auth_sources", :action => "update").should == "/auth_sources/update"
    end

    it "routes to #test_connection" do
      route_for(:controller => "auth_sources", :action => "test_connection").should == "/auth_sources/test_connection"
    end

    it "routes to #destroy" do
      route_for(:controller => "auth_sources", :action => "destroy").should == "/auth_sources/destroy"
    end

  end

end
