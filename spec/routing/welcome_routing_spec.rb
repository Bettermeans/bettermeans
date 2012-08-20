require 'spec_helper'

describe WelcomeController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "welcome", :action => "index").should == "/welcome"
    end

    it "routes to #robots" do
      route_for(:controller => "welcome", :action => "robots").should == "/welcome/robots"
    end

  end

end
