require 'spec_helper'

describe QuotesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "quotes", :action => "index").should == "/quotes"
    end

    it "routes to #show" do
      route_for(:controller => "quotes", :action => "show", :id => '5').should == "/quotes/5"
    end

    it "routes to #new" do
      route_for(:controller => "quotes", :action => "new").should == "/quotes/new"
    end

    it "routes to #edit" do
      route_for(:controller => "quotes", :action => "edit", :id => '5').should == "/quotes/5/edit"
    end

    it "routes to #create" do
      route_for(:controller => "quotes", :action => "create").should == { :path => "/quotes", :method => :post }
    end

    it "routes to #update" do
      route_for(:controller => "quotes", :action => "update", :id => '5').should == { :path => "/quotes/5", :method => :put }
    end

    it "routes to #destroy" do
      route_for(:controller => "quotes", :action => "destroy", :id => '5').should == { :path => "/quotes/5", :method => :delete }
    end

  end

end
