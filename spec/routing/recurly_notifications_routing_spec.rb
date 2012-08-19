require 'spec_helper'

describe RecurlyNotificationsController do

  describe "routing" do

    it "routes to #listen" do
      route_for(:controller => "recurly_notifications", :action => "listen").should == { :path => "/recurly_notifications/listen", :method => :post }
    end

  end

end
