require 'spec_helper'

describe IssueInvitationsController do

  describe "routing" do

    it "routes to #new" do
      route_for(:controller => "issue_invitations", :action => "new", :id => '5').should == "/issue_invitations/new/5"
    end

    it "routes to #create" do
      route_for(:controller => "issue_invitations", :action => "create", :id => '5').should == "/issue_invitations/create/5"
    end

  end

end
