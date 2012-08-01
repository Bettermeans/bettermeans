require 'spec_helper'

describe CreditTransfersController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "credit_transfers", :action => "index").should == "/credit_transfers"
    end

    it "routes to #show" do
      route_for(:controller => "credit_transfers", :action => "show", :id => "5").should == "/credit_transfers/show/5"
    end

    it "routes to #new" do
      route_for(:controller => "credit_transfers", :action => "new").should == "/credit_transfers/new"
    end

    it "routes to #edit" do
      route_for(:controller => "credit_transfers", :action => "edit", :id => "5").should == "/credit_transfers/edit/5"
    end

    it "routes to #create" do
      route_for(:controller => "credit_transfers", :action => "create").should == "/credit_transfers/create"
    end

    it "routes to #update" do
      route_for(:controller => "credit_transfers", :action => "update", :id => "5").should == "/credit_transfers/update/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "credit_transfers", :action => "destroy", :id => "5").should == "/credit_transfers/destroy/5"
    end

  end

end
