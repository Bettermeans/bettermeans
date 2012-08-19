require 'spec_helper'

describe RolesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "roles", :action => "index").should == "/roles"
    end

    it "routes to #list" do
      route_for(:controller => "roles", :action => "list").should == "/roles/list"
    end

    it "routes to #new" do
      route_for(:controller => "roles", :action => "new").should == "/roles/new"
    end

    it "routes to #edit" do
      route_for(:controller => "roles", :action => "edit", :id => '4').should == "/roles/edit/4"
      route_for(:controller => "roles", :action => "edit", :id => '4').should == { :path => "/roles/edit/4", :method => :post }
    end

    it "routes to #destroy" do
      route_for(:controller => "roles", :action => "destroy", :id => '4').should == { :path => "/roles/destroy/4", :method => :post }
    end

    it "routes to #report" do
      route_for(:controller => "roles", :action => "report", :id => '4').should == { :path => "/roles/report/4", :method => :post }
    end

  end

end
