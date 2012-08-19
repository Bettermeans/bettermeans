require 'spec_helper'

describe QueriesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "queries", :action => "index", :id => '5').should == "/queries/index/5"
    end

    it "routes to #new" do
      route_for(:controller => "queries", :action => "new", :id => '5').should == "/queries/new/5"
    end

    it "routes to #edit" do
      route_for(:controller => "queries", :action => "edit", :id => '5').should == "/queries/edit/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "queries", :action => "destroy", :id => '5').should == "/queries/destroy/5"
    end

  end

end
