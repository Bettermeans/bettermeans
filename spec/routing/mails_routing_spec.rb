require 'spec_helper'

describe MailsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "mails", :action => "index", :id => 'pie').should == "/mails/index/pie"
    end

    it "routes to #show" do
      route_for(:controller => "mails", :action => "show", :id => 'pie').should == "/mails/show/pie"
    end

    it "routes to #new" do
      route_for(:controller => "mails", :action => "new", :id => 'pie').should == "/mails/new/pie"
    end

    it "routes to #create" do
      route_for(:controller => "mails", :action => "create", :id => 'pie').should == { :path => "/mails/create/pie", :method => :post }
    end

    it "routes to #delete_selected" do
      route_for(:controller => "mails", :action => "delete_selected", :user_id => '5').should == { :path => "/users/5/mails/delete_selected", :method => :post }
    end

  end

end
