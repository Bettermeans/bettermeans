require 'spec_helper'

describe MembersController do

  describe "routing" do

    it "routes to #new" do
      route_for(:controller => "members", :action => "new", :id => 'pie').should == "/projects/pie/members/new"
    end

    it "routes to #edit" do
      route_for(:controller => "members", :action => "edit", :id => 'pie').should == "/members/edit/pie"
    end

    it "routes to #destroy" do
      route_for(:controller => "members", :action => "destroy", :id => 'pie').should == { :path => "/members/destroy/pie", :method => :post }
    end

    it "routes to #autocomplete_for_member" do
      route_for(:controller => "members", :action => "autocomplete_for_member").should == "/members/autocomplete_for_member"
    end

  end

end
