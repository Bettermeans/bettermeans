require 'spec_helper'

describe EnumerationsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "enumerations", :action => "index").should == "/enumerations"
    end

    it "routes to #list" do
      route_for(:controller => "enumerations", :action => "list").should == "/enumerations/list"
    end

    it "routes to #new" do
      route_for(:controller => "enumerations", :action => "new").should == "/enumerations/new"
    end

    it "routes to #create" do
      route_for(:controller => "enumerations", :action => "create").should == "/enumerations/create"
    end

    it "routes to #edit" do
      route_for(:controller => "enumerations", :action => "edit", :id => '5').should == "/enumerations/edit/5"
    end

    it "routes to #update" do
      route_for(:controller => "enumerations", :action => "update", :id => '5').should == "/enumerations/update/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "enumerations", :action => "destroy").should == "/enumerations/destroy"
    end

  end

end
