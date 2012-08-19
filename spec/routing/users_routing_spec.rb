require 'spec_helper'

describe UsersController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "users", :action => "index").should == "/users"
    end

    it "routes to #show" do
      route_for(:controller => "users", :action => "show", :id => '4').should == "/users/4"
    end

    it "routes to #add" do
      route_for(:controller => "users", :action => "add").should == { :path => "/users/new", :method => :post }
    end

    it "routes to #edit" do
      route_for(:controller => "users", :action => "edit", :id => '4', :tab => 'stuff').should == "/users/4/edit/stuff"
      route_for(:controller => "users", :action => "edit", :id => '4').should == { :path => "/users/4/edit", :method => :post }
    end

    it "routes to #edit_membership" do
      route_for(:controller => "users", :action => "edit_membership", :id => '4').should == { :path => "/users/4/memberships", :method => :post }
      route_for(:controller => "users", :action => "edit_membership", :id => '4', :membership_id => '5').should == { :path => "/users/4/memberships/5", :method => :post }
    end

    it "routes to #destroy_membership" do
      route_for(:controller => "users", :action => "destroy_membership", :id => '4', :membership_id => '5').should == { :path => "/users/4/memberships/5/destroy", :method => :post }
    end

  end

end
