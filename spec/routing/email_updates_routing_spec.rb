require 'spec_helper'

describe EmailUpdatesController do

  describe "routing" do

    it "routes to #new" do
      route_for(:controller => "email_updates", :action => "new").should == "/email_updates/new"
    end

    it "routes to #create" do
      route_for(:controller => "email_updates", :action => "create").should == {:path => "/email_updates", :method => :post }
    end

    it "routes to #activate" do
      route_for(:controller => "email_updates", :action => "activate").should == "/email_updates/activate"
    end

  end

end
