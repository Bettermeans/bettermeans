require 'spec_helper'

describe MotionVotesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "motion_votes", :action => "index", :id => '5').should == "/motion_votes/index/5"
    end

    it "routes to #show" do
      route_for(:controller => "motion_votes", :action => "show", :id => '5').should == "/motion_votes/show/5"
    end

    it "routes to #new" do
      route_for(:controller => "motion_votes", :action => "new", :id => '5').should == "/motion_votes/new/5"
    end

    it "routes to #edit" do
      route_for(:controller => "motion_votes", :action => "edit", :id => '5').should == "/motion_votes/edit/5"
    end

    it "routes to #create" do
      route_for(:controller => "motion_votes", :action => "create", :id => '5').should == "/motion_votes/create/5"
    end

    it "routes to #update" do
      route_for(:controller => "motion_votes", :action => "update", :id => '5').should == "/motion_votes/update/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "motion_votes", :action => "destroy", :id => '5').should == "/motion_votes/destroy/5"
    end

  end

end
