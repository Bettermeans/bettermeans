require 'spec_helper'

describe SettingsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "settings", :action => "index").should == "/settings"
    end

    it "routes to #edit" do
      route_for(:controller => "settings", :action => "edit", :id => '5').should == "/settings/edit/5"
      route_for(:controller => "settings", :action => "edit", :id => '5').should == { :path => "/settings/edit/5", :method => :post }
    end

    it "routes to #plugin" do
      route_for(:controller => "settings", :action => "plugin", :id => '5').should == "/settings/plugin/5"
      route_for(:controller => "settings", :action => "plugin", :id => '5').should == { :path => "/settings/plugin/5", :method => :post }
    end

  end

end
