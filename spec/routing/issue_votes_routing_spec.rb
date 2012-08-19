require 'spec_helper'

describe IssueVotesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "issue_votes", :action => "index", :id => '5').should == "/issue_votes/index/5"
    end

    it "routes to #show" do
      route_for(:controller => "issue_votes", :action => "show", :id => '5').should == "/issue_votes/show/5"
    end

    it "routes to #new" do
      route_for(:controller => "issue_votes", :action => "new", :id => '5').should == "/issue_votes/new/5"
    end

    it "routes to #edit" do
      route_for(:controller => "issue_votes", :action => "edit", :id => '5').should == "/issue_votes/edit/5"
    end

    it "routes to #create" do
      route_for(:controller => "issue_votes", :action => "create", :id => '5').should == "/issue_votes/create/5"
    end

    it "routes to #update" do
      route_for(:controller => "issue_votes", :action => "update", :id => '5').should == "/issue_votes/update/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "issue_votes", :action => "destroy", :id => '5').should == "/issue_votes/destroy/5"
    end

  end

end
