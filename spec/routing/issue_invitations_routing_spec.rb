require 'spec_helper'

describe IssueInvitationsController do

  describe "routing" do

    it "routes to #new" do
      route_for(:controller => "issue_invitations", :action => "new", :id => 'pie').should == "/issue_invitations/new/pie"
    end

    it "routes to #create" do
      route_for(:controller => "issue_invitations", :action => "create", :id => 'pie').should == "/issue_invitations/create/pie"
    end

  end

end
