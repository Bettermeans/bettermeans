require 'spec_helper'

describe HomeController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "home", :action => "index").should == "/"
    end

    it "routes to #show" do
      route_for(:controller => "home", :action => "show", :page => "index.html").should == "/front/index.html"
    end

    it "routes to #robots" do
      route_for(:controller => "home", :action => "robots").should == "/home/robots"
    end

  end

end
