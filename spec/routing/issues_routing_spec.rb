require 'spec_helper'

describe IssuesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "issues", :action => "index").should == "/issues"
      route_for(:controller => "issues", :action => "index", :project_id => 'pizza').should == "/projects/pizza/issues"
    end

    it "routes to #show" do
      route_for(:controller => "issues", :action => "show", :id => '5').should == "/issues/5/show"
    end

    it "routes to #new" do
      route_for(:controller => "issues", :action => "new", :project_id => 'pizza').should == "/projects/pizza/issues/new"
      route_for(:controller => "issues", :action => "new", :project_id => 'pizza', :copy_from => 'pie').should == "/projects/pizza/issues/pie/copy"
    end

    it "routes to #edit" do
      route_for(:controller => "issues", :action => "edit", :id => '5').should == "/issues/5/edit"
      route_for(:controller => "issues", :action => "edit", :id => '5').should == { :path => "/issues/5/edit", :method => :post }
    end

    it "routes to #start" do
      route_for(:controller => "issues", :action => "start", :id => '5').should == { :path => "/issues/5/start", :method => :post }
    end

    it "routes to #finish" do
      route_for(:controller => "issues", :action => "finish", :id => '5').should == { :path => "/issues/5/finish", :method => :post }
    end

    it "routes to #release" do
      route_for(:controller => "issues", :action => "release", :id => '5').should == { :path => "/issues/5/release", :method => :post }
    end

    it "routes to #cancel" do
      route_for(:controller => "issues", :action => "cancel", :id => '5').should == { :path => "/issues/5/cancel", :method => :post }
    end

    it "routes to #restart" do
      route_for(:controller => "issues", :action => "restart", :id => '5').should == { :path => "/issues/5/restart", :method => :post }
    end

    it "routes to #change_status" do
      route_for(:controller => "issues", :action => "change_status", :id => 'pie').should == "/issues/change_status/pie"
    end

    it "routes to #prioritize" do
      route_for(:controller => "issues", :action => "prioritize", :id => '5').should == { :path => "/issues/5/prioritize", :method => :post }
    end

    it "routes to #update_tags" do
      route_for(:controller => "issues", :action => "update_tags", :id => '5').should == { :path => "/issues/5/update_tags", :method => :post }
    end

    it "routes to #estimate" do
      route_for(:controller => "issues", :action => "estimate", :id => '5').should == { :path => "/issues/5/estimate", :method => :post }
    end

    it "routes to #agree" do
      route_for(:controller => "issues", :action => "agree", :id => '5').should == { :path => "/issues/5/agree", :method => :post }
    end

    it "routes to #accept" do
      route_for(:controller => "issues", :action => "accept", :id => '5').should == { :path => "/issues/5/accept", :method => :post }
    end

    it "routes to #join" do
      route_for(:controller => "issues", :action => "join", :id => '5').should == { :path => "/issues/5/join", :method => :post }
    end

    it "routes to #add_team_member" do
      route_for(:controller => "issues", :action => "add_team_member", :id => '5').should == { :path => "/issues/5/add_team_member", :method => :post }
    end

    it "routes to #remove_team_member" do
      route_for(:controller => "issues", :action => "remove_team_member", :id => 'pie').should == "/issues/remove_team_member/pie"
    end

    it "routes to #leave" do
      route_for(:controller => "issues", :action => "leave", :id => '5').should == { :path => "/issues/5/leave", :method => :post }
    end

    it "routes to #reply" do
      route_for(:controller => "issues", :action => "reply", :id => '5').should == { :path => "/issues/5/quoted", :method => :post }
    end

    it "routes to #bulk_edit" do
      route_for(:controller => "issues", :action => "bulk_edit", :id => 'pie').should == "/issues/bulk_edit/pie"
    end

    it "routes to #move" do
      route_for(:controller => "issues", :action => "move", :id => '5').should == "/issues/5/move"
      route_for(:controller => "issues", :action => "move", :id => '5').should == { :path => "/issues/5/move", :method => :post }
    end

    it "routes to #destroy" do
      route_for(:controller => "issues", :action => "destroy", :id => '5').should == { :path => "/issues/5/destroy", :method => :post }
    end

    it "routes to #gantt" do
      route_for(:controller => "issues", :action => "gantt", :project_id => 'pie').should == "/projects/pie/issues/gantt"
    end

    it "routes to #calendar" do
      route_for(:controller => "issues", :action => "calendar", :project_id => 'pie').should == "/projects/pie/issues/calendar"
    end

    it "routes to #context_menu" do
      route_for(:controller => "issues", :action => "context_menu", :id => 'pie').should == "/issues/context_menu/pie"
    end

    it "routes to #update_form" do
      route_for(:controller => "issues", :action => "update_form", :id => 'pie').should == "/issues/update_form/pie"
    end

    it "routes to #preview" do
      route_for(:controller => "issues", :action => "preview", :id => 'pie').should == "/issues/preview/pie"
    end

    it "routes to #datadump" do
      route_for(:controller => "issues", :action => "datadump").should == "/issues/datadump"
    end

  end

end
