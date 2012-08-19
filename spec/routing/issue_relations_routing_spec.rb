require 'spec_helper'

describe IssueRelationsController do

  describe "routing" do

    it "routes to #new" do
      route_for(:controller => "issue_relations", :action => "new", :id => '5').should == "/issue_relations/new/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "issue_relations", :action => "destroy", :id => '5').should == "/issue_relations/destroy/5"
    end

  end

end
