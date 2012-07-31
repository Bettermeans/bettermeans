require 'spec_helper'

describe AccountController do

  describe "routing" do

    it "routes to #login" do
      route_for(:controller => "account", :action => "login").should == "/login"
    end

    it "routes to #rpx_token" do
      route_for(:controller => "account", :action => "rpx_token").should == "/accounts/rpx_token"
    end

    it "routes to #logout" do
      route_for(:controller => "account", :action => "logout").should == "/logout"
    end

    it "routes to #lost_password" do
      route_for(:controller => "account", :action => "lost_password").should == "/account/lost_password"
    end

    it "routes to #register" do
      route_for(:controller => "account", :action => "register").should == "/account/register"
    end

    it "routes to #activate" do
      route_for(:controller => "account", :action => "activate").should == "/account/activate"
    end

    it "routes to #cancel" do
      route_for(:controller => "account", :action => "cancel").should == "/account/cancel"
    end

  end

end
