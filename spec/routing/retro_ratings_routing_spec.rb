require 'spec_helper'

describe RetroRatingsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "retro_ratings", :action => "index", :id => '5').should == "/retro_ratings/index/5"
    end

    it "routes to #show" do
      route_for(:controller => "retro_ratings", :action => "show", :id => '5').should == "/retro_ratings/show/5"
    end

    it "routes to #new" do
      route_for(:controller => "retro_ratings", :action => "new", :id => '5').should == "/retro_ratings/new/5"
    end

    it "routes to #edit" do
      route_for(:controller => "retro_ratings", :action => "edit", :id => '5').should == "/retro_ratings/edit/5"
    end

    it "routes to #create" do
      route_for(:controller => "retro_ratings", :action => "create", :id => '5').should == "/retro_ratings/create/5"
    end

    it "routes to #update" do
      route_for(:controller => "retro_ratings", :action => "update", :id => '5').should == "/retro_ratings/update/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "retro_ratings", :action => "destroy", :id => '5').should == "/retro_ratings/destroy/5"
    end

  end

end
