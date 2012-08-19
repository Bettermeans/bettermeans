require 'spec_helper'

describe MotionsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "motions", :action => "index", :project_id => '5').should == "projects/5/motions"
    end

    it "routes to #show" do
      route_for(:controller => "motions", :action => "show", :project_id => '5', :id => '4').should == "projects/5/motions/4"
    end

    it "routes to #new" do
      route_for(:controller => "motions", :action => "new", :project_id => '5').should == "projects/5/motions/new"
    end

    it "routes to #eligible_users" do
      route_for(:controller => "motions", :action => "eligible_users", :id => '5').should == "/motions/eligible_users/5"
    end

    it "routes to #edit" do
      route_for(:controller => "motions", :action => "edit", :project_id => '5', :id => '4').should == "projects/5/motions/4/edit"
    end

    it "routes to #create" do
      route_for(:controller => "motions", :action => "create", :project_id => '5').should == { :path => "projects/5/motions", :method => :post }
    end

    it "routes to #update" do
      route_for(:controller => "motions", :action => "update", :project_id => '5', :id => '4').should == { :path => "projects/5/motions/4", :method => :put }
    end

    it "routes to #destroy" do
      route_for(:controller => "motions", :action => "destroy", :project_id => '5', :id => '4').should == { :path => "projects/5/motions/4", :method => :delete }
    end

    it "routes to #reply" do
      route_for(:controller => "motions", :action => "reply", :id => '5').should == "/motions/reply/5"
    end

  end

end
