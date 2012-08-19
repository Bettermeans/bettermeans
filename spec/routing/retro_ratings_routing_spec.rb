require 'spec_helper'

describe RetroRatingsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "retro_ratings", :action => "index", :id => 'pie').should == "/retro_ratings/index/pie"
    end

    it "routes to #show" do
      route_for(:controller => "retro_ratings", :action => "show", :id => 'pie').should == "/retro_ratings/show/pie"
    end

    it "routes to #new" do
      route_for(:controller => "retro_ratings", :action => "new", :id => 'pie').should == "/retro_ratings/new/pie"
    end

    it "routes to #edit" do
      route_for(:controller => "retro_ratings", :action => "edit", :id => 'pie').should == "/retro_ratings/edit/pie"
    end

    it "routes to #create" do
      route_for(:controller => "retro_ratings", :action => "create", :id => 'pie').should == "/retro_ratings/create/pie"
    end

    it "routes to #update" do
      route_for(:controller => "retro_ratings", :action => "update", :id => 'pie').should == "/retro_ratings/update/pie"
    end

    it "routes to #destroy" do
      route_for(:controller => "retro_ratings", :action => "destroy", :id => 'pie').should == "/retro_ratings/destroy/pie"
    end

  end

end
