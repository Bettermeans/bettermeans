require 'spec_helper'

describe WikisController do

  describe "routing" do

    it "routes to #edit" do
      route_for(:controller => "wikis", :action => "edit", :id => '5').should == { :path => "/projects/5/wiki", :method => :post }
    end

    it "routes to #destroy" do
      route_for(:controller => "wikis", :action => "destroy", :id => '5').should == "/projects/5/wiki/destroy"
      route_for(:controller => "wikis", :action => "destroy", :id => '5').should == { :path => "/projects/5/wiki/destroy", :method => :post }
    end

  end

end
