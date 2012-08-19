require 'spec_helper'

describe ReputationsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "reputations", :action => "index").should == "/reputations"
    end

    it "routes to #show" do
      route_for(:controller => "reputations", :action => "show", :id => '5').should == "/reputations/5"
    end

    it "routes to #new" do
      route_for(:controller => "reputations", :action => "new").should == "/reputations/new"
    end

    it "routes to #edit" do
      route_for(:controller => "reputations", :action => "edit", :id => '5').should == "/reputations/5/edit"
    end

    it "routes to #create" do
      route_for(:controller => "reputations", :action => "create").should == { :path => "/reputations", :method => :post }
    end

    it "routes to #update" do
      route_for(:controller => "reputations", :action => "update", :id => '5').should == { :path => "/reputations/5", :method => :put }
    end

    it "routes to #destroy" do
      route_for(:controller => "reputations", :action => "destroy", :id => '5').should == { :path => "/reputations/5", :method => :delete }
    end

  end

end
