require 'spec_helper'

describe CreditDistributionsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "credit_distributions", :action => "index").should == "/credit_distributions"
    end

    it "routes to #show" do
      route_for(:controller => "credit_distributions", :action => "show", :id => "5").should == "/credit_distributions/5"
    end

    it "routes to #new" do
      route_for(:controller => "credit_distributions", :action => "new").should == "/credit_distributions/new"
    end

    it "routes to #edit" do
      route_for(:controller => "credit_distributions", :action => "edit", :id => "5").should == "/credit_distributions/5/edit"
    end

    it "routes to #create" do
      route_for(:controller => "credit_distributions", :action => "create").should == { :path => "/credit_distributions", :method => :post }
    end

    it "routes to #update" do
      route_for(:controller => "credit_distributions", :action => "update", :id => "5").should == { :path => "/credit_distributions/5", :method => :put }
    end

    it "routes to #destroy" do
      route_for(:controller => "credit_distributions", :action => "destroy", :id => "5").should == { :path => "/credit_distributions/5", :method => :delete }
    end

  end

end
