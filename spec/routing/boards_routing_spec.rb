require 'spec_helper'

describe BoardsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "boards", :action => "index").should == "/boards"
    end

    it "routes to #show" do
      route_for(:controller => "boards", :action => "show").should == "/boards/show"
    end

    it "routes to #new" do
      route_for(:controller => "boards", :action => "new").should == "/boards/new"
    end

    it "routes to #edit" do
      route_for(:controller => "boards", :action => "edit").should == "/boards/edit"
    end

    it "routes to #destroy" do
      route_for(:controller => "boards", :action => "destroy").should == "/boards/destroy"
    end

  end

end
