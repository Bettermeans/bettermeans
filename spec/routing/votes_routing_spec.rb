require 'spec_helper'

describe TodosController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "votes", :action => "index").should == "/votes"
    end

    it "routes to #show" do
      route_for(:controller => "votes", :action => "show", :id => '4').should == "/votes/show/4"
    end

    it "routes to #new" do
      route_for(:controller => "votes", :action => "new").should == "/votes/new"
    end

    it "routes to #edit" do
      route_for(:controller => "votes", :action => "edit", :id => '4').should == "/votes/edit/4"
    end

    it "routes to #create" do
      route_for(:controller => "votes", :action => "create").should == "/votes/create"
    end

    it "routes to #update" do
      route_for(:controller => "votes", :action => "update", :id => '4').should == "/votes/update/4"
    end

    it "routes to #destroy" do
      route_for(:controller => "votes", :action => "destroy", :id => '4').should == "/votes/destroy/4"
    end

  end

end
