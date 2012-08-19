require 'spec_helper'

describe ProjectsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "projects", :action => "index").should == "/projects"
    end

    it "routes to #index_latest" do
      route_for(:controller => "projects", :action => "index_latest").should == "/projects/index_latest"
    end

    it "routes to #index_active" do
      route_for(:controller => "projects", :action => "index_active").should == "/projects/index_active"
    end

    it "routes to #map" do
      route_for(:controller => "projects", :action => "map", :id => '5').should == "/projects/5/map"
    end

    it "routes to #add" do
      route_for(:controller => "projects", :action => "add").should == "/projects/new"
      route_for(:controller => "projects", :action => "add").should == { :path => "/projects/new", :method => :post }
      params_from(:post, "/projects").should == { :controller => "projects", :action => "add" }
    end

    it "routes to #copy" do
      route_for(:controller => "projects", :action => "copy", :id => '5').should == "/projects/copy/5"
    end

    it "routes to #reset_invitation_token" do
      route_for(:controller => "projects", :action => "reset_invitation_token", :id => '5').should == "/projects/reset_invitation_token/5"
    end

    it "routes to #join" do
      route_for(:controller => "projects", :action => "join", :id => '5').should == "/projects/5/join"
    end

    it "routes to #overview" do
      route_for(:controller => "projects", :action => "overview", :id => '5').should == "/projects/5"
      params_from(:get, "/projects/5/show").should == { :controller => "projects", :action => "overview", :id => '5' }
      params_from(:get, "/projects/5/overview").should == { :controller => "projects", :action => "overview", :id => '5' }
    end

    it "routes to #hourly_types" do
      route_for(:controller => "projects", :action => "hourly_types", :id => '5').should == "/projects/5/hourly_types"
    end

    it "routes to #community_members" do
      route_for(:controller => "projects", :action => "community_members", :id => '5').should == "/projects/5/community_members"
    end

    it "routes to #community_members_array" do
      route_for(:controller => "projects", :action => "community_members_array", :id => '5').should == "/projects/5/community_members_array"
    end

    it "routes to #issue_search" do
      route_for(:controller => "projects", :action => "issue_search", :id => '5').should == "/projects/5/issue_search"
    end

    it "routes to #all_tags" do
      route_for(:controller => "projects", :action => "all_tags", :id => '5').should == "/projects/5/all_tags"
    end

    it "routes to #dashboard" do
      route_for(:controller => "projects", :action => "dashboard", :id => '5').should == "/projects/5/dashboard"
      route_for(:controller => "projects", :action => "dashboard", :show_issue_id => '5').should == "/issues/5"
    end

    it "routes to #dashdata" do
      route_for(:controller => "projects", :action => "dashdata", :id => '5').should == "/projects/5/dashdata"
    end

    it "routes to #new_dashdata" do
      route_for(:controller => "projects", :action => "new_dashdata", :id => '5').should == "/projects/5/new_dashdata"
    end

    it "routes to #update_scale" do
      route_for(:controller => "projects", :action => "update_scale").should == "/projects/update_scale"
    end

    it "routes to #mypris" do
      route_for(:controller => "projects", :action => "mypris", :id => '5').should == "/projects/5/mypris"
    end

    it "routes to #settings" do
      route_for(:controller => "projects", :action => "settings", :id => '5').should == "/projects/5/settings"
      route_for(:controller => "projects", :action => "settings", :id => '5', :tab => '4').should == "/projects/5/settings/4"
    end

    it "routes to #edit" do
      route_for(:controller => "projects", :action => "edit", :id => '5').should == { :path => "/projects/5/edit", :method => :post }
    end

    it "routes to #modules" do
      route_for(:controller => "projects", :action => "modules", :id => '5').should == "/projects/modules/5"
    end

    it "routes to #archive" do
      route_for(:controller => "projects", :action => "archive", :id => '5').should == { :path => "/projects/5/archive", :method => :post }
    end

    it "routes to #unarchive" do
      route_for(:controller => "projects", :action => "unarchive", :id => '5').should == { :path => "/projects/5/unarchive", :method => :post }
    end

    it "routes to #destroy" do
      route_for(:controller => "projects", :action => "destroy", :id => '5').should == "/projects/5/destroy"
      route_for(:controller => "projects", :action => "destroy", :id => '5').should == { :path => "/projects/5/destroy", :method => :post }
    end

    it "routes to #move" do
      route_for(:controller => "projects", :action => "move", :id => '5').should == "/projects/move/5"
    end

    it "routes to #add_file" do
      route_for(:controller => "projects", :action => "add_file", :id => '5').should == "/projects/5/files/new"
      route_for(:controller => "projects", :action => "add_file", :id => '5').should == { :path => "/projects/5/files/new", :method => :post }
    end

    it "routes to #list_files" do
      route_for(:controller => "projects", :action => "list_files", :id => '5').should == "/projects/5/files"
    end

    it "routes to #team" do
      route_for(:controller => "projects", :action => "team", :id => '5').should == "/projects/5/team"
    end

    it "routes to #credits" do
      route_for(:controller => "projects", :action => "credits", :id => '5').should == "/projects/5/credits"
    end

    it "routes to #activity" do
      route_for(:controller => "projects", :action => "activity", :id => '5').should == "/projects/5/activity"
      route_for(:controller => "projects", :action => "activity", :id => nil).should == "/activity"
    end

  end

end
