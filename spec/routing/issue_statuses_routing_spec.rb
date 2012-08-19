require 'spec_helper'

describe IssueStatusesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "issue_statuses", :action => "index", :id => '5').should == "/issue_statuses/index/5"
    end

    it "routes to #list" do
      route_for(:controller => "issue_statuses", :action => "list", :id => '5').should == "/issue_statuses/list/5"
    end

    it "routes to #new" do
      route_for(:controller => "issue_statuses", :action => "new", :id => '5').should == "/issue_statuses/new/5"
    end

    it "routes to #create" do
      route_for(:controller => "issue_statuses", :action => "create", :id => '5').should == "/issue_statuses/create/5"
    end

    it "routes to #edit" do
      route_for(:controller => "issue_statuses", :action => "edit", :id => '5').should == "/issue_statuses/edit/5"
    end

    it "routes to #update" do
      route_for(:controller => "issue_statuses", :action => "update", :id => '5').should == "/issue_statuses/update/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "issue_statuses", :action => "destroy", :id => '5').should == "/issue_statuses/destroy/5"
    end

  end

end
