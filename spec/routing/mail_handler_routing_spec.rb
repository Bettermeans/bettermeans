require 'spec_helper'

describe MailHandlerController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "mail_handler", :action => "index", :id => 'pie').should == "/mail_handler/index/pie"
    end

    it "routes to #sendgrid" do
      route_for(:controller => "mail_handler", :action => "sendgrid", :id => 'pie').should == "/mail_handler/sendgrid/pie"
    end

  end

end
