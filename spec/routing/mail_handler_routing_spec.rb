require 'spec_helper'

describe MailHandlerController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "mail_handler", :action => "index", :id => '5').should == "/mail_handler/index/5"
    end

    it "routes to #sendgrid" do
      route_for(:controller => "mail_handler", :action => "sendgrid", :id => '5').should == "/mail_handler/sendgrid/5"
    end

  end

end
