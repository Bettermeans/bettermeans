require 'spec_helper'

describe WorkflowsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "workflows", :action => "index").should == "/workflows"
    end

    it "routes to #edit" do
      route_for(:controller => "workflows", :action => "edit", :id => '5').should == "/workflows/edit/5"
      route_for(:controller => "workflows", :action => "edit", :id => '5').should == { :path => "/workflows/edit/5", :method => :post }
    end

    it "routes to #copy" do
      route_for(:controller => "workflows", :action => "copy", :id => '5').should == "/workflows/copy/5"
      route_for(:controller => "workflows", :action => "copy", :id => '5').should == { :path => "/workflows/copy/5", :method => :post }
    end

  end

end
