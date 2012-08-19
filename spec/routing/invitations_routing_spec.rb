require 'spec_helper'

describe InvitationsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "invitations", :action => "index", :id => '5').should == "/invitations/index/5"
    end

    it "routes to #show" do
      route_for(:controller => "invitations", :action => "show", :id => '5').should == "/invitations/show/5"
    end

    it "routes to #new" do
      route_for(:controller => "invitations", :action => "new", :id => '5').should == "/invitations/new/5"
    end

    it "routes to #edit" do
      route_for(:controller => "invitations", :action => "edit", :id => '5').should == "/invitations/edit/5"
    end

    it "routes to #create" do
      route_for(:controller => "invitations", :action => "create", :id => '5').should == "/invitations/create/5"
    end

    it "routes to #accept" do
      route_for(:controller => "invitations", :action => "accept", :id => "5").should == "/invitations/5"
    end

    it "routes to #resend" do
      route_for(:controller => "invitations", :action => "resend", :project_id => "4", :id => "5").should == { :path => "/projects/4/invitations/5/resend", :method => :post }
    end

    it "routes to #destroy" do
      route_for(:controller => "invitations", :action => "destroy", :project_id => "4", :id => "5").should == { :path => "/projects/4/invitations/5/destroy", :method => :post }
    end

  end

end
