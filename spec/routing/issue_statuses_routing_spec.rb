require 'spec_helper'

describe IssueStatusesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "issue_statuses", :action => "index", :id => 'pie').should == "/issue_statuses/index/pie"
    end

    it "routes to #list" do
      route_for(:controller => "issue_statuses", :action => "list", :id => 'pie').should == "/issue_statuses/list/pie"
    end

    it "routes to #new" do
      route_for(:controller => "issue_statuses", :action => "new", :id => 'pie').should == "/issue_statuses/new/pie"
    end

    it "routes to #create" do
      route_for(:controller => "issue_statuses", :action => "create", :id => 'pie').should == "/issue_statuses/create/pie"
    end

    it "routes to #edit" do
      route_for(:controller => "issue_statuses", :action => "edit", :id => 'pie').should == "/issue_statuses/edit/pie"
    end

    it "routes to #update" do
      route_for(:controller => "issue_statuses", :action => "update", :id => 'pie').should == "/issue_statuses/update/pie"
    end

    it "routes to #destroy" do
      route_for(:controller => "issue_statuses", :action => "destroy", :id => 'pie').should == "/issue_statuses/destroy/pie"
    end

  end

end
