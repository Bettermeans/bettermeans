require 'spec_helper'

describe IssueVotesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "issue_votes", :action => "index", :id => 'pie').should == "/issue_votes/index/pie"
    end

    it "routes to #show" do
      route_for(:controller => "issue_votes", :action => "show", :id => 'pie').should == "/issue_votes/show/pie"
    end

    it "routes to #new" do
      route_for(:controller => "issue_votes", :action => "new", :id => 'pie').should == "/issue_votes/new/pie"
    end

    it "routes to #edit" do
      route_for(:controller => "issue_votes", :action => "edit", :id => 'pie').should == "/issue_votes/edit/pie"
    end

    it "routes to #create" do
      route_for(:controller => "issue_votes", :action => "create", :id => 'pie').should == "/issue_votes/create/pie"
    end

    it "routes to #update" do
      route_for(:controller => "issue_votes", :action => "update", :id => 'pie').should == "/issue_votes/update/pie"
    end

    it "routes to #destroy" do
      route_for(:controller => "issue_votes", :action => "destroy", :id => 'pie').should == "/issue_votes/destroy/pie"
    end

  end

end
