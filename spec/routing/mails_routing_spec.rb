require 'spec_helper'

describe MailsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "mails", :action => "index", :id => '5').should == "/mails/index/5"
    end

    it "routes to #show" do
      route_for(:controller => "mails", :action => "show", :id => '5').should == "/mails/show/5"
    end

    it "routes to #new" do
      route_for(:controller => "mails", :action => "new", :id => '5').should == "/mails/new/5"
    end

    it "routes to #create" do
      route_for(:controller => "mails", :action => "create", :id => '5').should == { :path => "/mails/create/5", :method => :post }
    end

    it "routes to #delete_selected" do
      route_for(:controller => "mails", :action => "delete_selected", :user_id => '5').should == { :path => "/users/5/mails/delete_selected", :method => :post }
    end

  end

end
