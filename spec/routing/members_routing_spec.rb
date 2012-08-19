require 'spec_helper'

describe MembersController do

  describe "routing" do

    it "routes to #new" do
      route_for(:controller => "members", :action => "new", :id => '5').should == "/projects/5/members/new"
    end

    it "routes to #edit" do
      route_for(:controller => "members", :action => "edit", :id => '5').should == "/members/edit/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "members", :action => "destroy", :id => '5').should == { :path => "/members/destroy/5", :method => :post }
    end

    it "routes to #autocomplete_for_member" do
      route_for(:controller => "members", :action => "autocomplete_for_member").should == "/members/autocomplete_for_member"
    end

  end

end
