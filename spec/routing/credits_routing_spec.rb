require 'spec_helper'

describe CreditsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "credits", :action => "index").should == "/credits"
    end

    it "routes to #show" do
      route_for(:controller => "credits", :action => "show", :id => "5").should == "/credits/show/5"
    end

    it "routes to #new" do
      route_for(:controller => "credits", :action => "new").should == "/credits/new"
    end

    it "routes to #edit" do
      route_for(:controller => "credits", :action => "edit", :id => "5").should == "/credits/edit/5"
    end

    it "routes to #create" do
      route_for(:controller => "credits", :action => "create").should == "/credits/create"
    end

    it "routes to #update" do
      route_for(:controller => "credits", :action => "update", :id => "5").should == "/credits/update/5"
    end

    it "routes to #disable" do
      route_for(:controller => "credits", :action => "disable").should == "/credits/disable"
    end

    it "routes to #enable" do
      route_for(:controller => "credits", :action => "enable").should == "/credits/enable"
    end

    it "routes to #update_credit_partials" do
      route_for(:controller => "credits", :action => "update_credit_partials").should == "/credits/update_credit_partials"
    end

    it "routes to #destroy" do
      route_for(:controller => "credits", :action => "destroy", :id => "5").should == "/credits/destroy/5"
    end

  end

end
