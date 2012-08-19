require 'spec_helper'

describe SharesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "shares", :action => "index").should == "/shares"
    end

    it "routes to #show" do
      route_for(:controller => "shares", :action => "show", :id => '4').should == "/shares/show/4"
    end

    it "routes to #new" do
      route_for(:controller => "shares", :action => "new").should == "/shares/new"
    end

    it "routes to #edit" do
      route_for(:controller => "shares", :action => "edit", :id => '4').should == "/shares/edit/4"
    end

    it "routes to #create" do
      route_for(:controller => "shares", :action => "create").should == "/shares/create"
    end

    it "routes to #update" do
      route_for(:controller => "shares", :action => "update", :id => '4').should == "/shares/update/4"
    end

    it "routes to #destroy" do
      route_for(:controller => "shares", :action => "destroy", :id => '4').should == "/shares/destroy/4"
    end

  end

end
