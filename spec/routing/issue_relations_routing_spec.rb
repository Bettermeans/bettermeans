require 'spec_helper'

describe IssueRelationsController do

  describe "routing" do

    it "routes to #new" do
      route_for(:controller => "issue_relations", :action => "new", :id => 'pie').should == "/issue_relations/new/pie"
    end

    it "routes to #destroy" do
      route_for(:controller => "issue_relations", :action => "destroy", :id => 'pie').should == "/issue_relations/destroy/pie"
    end

  end

end
