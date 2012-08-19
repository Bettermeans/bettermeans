require 'spec_helper'

describe MyController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "my", :action => "index", :id => '5').should == "/my/index/5"
    end

    it "routes to #page" do
      route_for(:controller => "my", :action => "page", :id => '5').should == "/my/page/5"
    end

    it "routes to #projects" do
      route_for(:controller => "my", :action => "projects", :id => '5').should == "/my/projects/5"
    end

    it "routes to #issues" do
      route_for(:controller => "my", :action => "issues", :id => '5').should == "/my/issues/5"
    end

    it "routes to #account" do
      route_for(:controller => "my", :action => "account", :id => '5').should == "/my/account/5"
    end

    it "routes to #upgrade" do
      route_for(:controller => "my", :action => "upgrade", :id => '5').should == "/my/upgrade/5"
    end

    it "routes to #password" do
      route_for(:controller => "my", :action => "password", :id => '5').should == "/my/password/5"
    end

    it "routes to #reset_rss_key" do
      route_for(:controller => "my", :action => "reset_rss_key", :id => '5').should == "/my/reset_rss_key/5"
    end

    it "routes to #reset_api_key" do
      route_for(:controller => "my", :action => "reset_api_key", :id => '5').should == "/my/reset_api_key/5"
    end

    it "routes to #page_layout" do
      route_for(:controller => "my", :action => "page_layout", :id => '5').should == "/my/page_layout/5"
    end

    it "routes to #add_block" do
      route_for(:controller => "my", :action => "add_block", :id => '5').should == "/my/add_block/5"
    end

    it "routes to #remove_block" do
      route_for(:controller => "my", :action => "remove_block", :id => '5').should == "/my/remove_block/5"
    end

    it "routes to #order_blocks" do
      route_for(:controller => "my", :action => "order_blocks", :id => '5').should == "/my/order_blocks/5"
    end

  end

end
