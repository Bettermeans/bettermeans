require 'spec_helper'

describe MessagesController do

  describe "routing" do

    it "routes to #show" do
      route_for(:controller => "messages", :action => "show", :board_id => '5', :id => '4').should == "/boards/5/topics/4"
    end

    it "routes to #new" do
      route_for(:controller => "messages", :action => "new", :board_id => '5').should == "/boards/5/topics/new"
      route_for(:controller => "messages", :action => "new", :board_id => '5').should == { :path => "/boards/5/topics/new", :method => :post }
    end

    it "routes to #reply" do
      route_for(:controller => "messages", :action => "reply", :board_id => '5', :id => '4').should == { :path => "/boards/5/topics/4/replies", :method => :post }
    end

    it "routes to #edit" do
      route_for(:controller => "messages", :action => "edit", :board_id => '5', :id => '4').should == { :path => "/boards/5/topics/4/edit", :method => :post }
    end

    it "routes to #destroy" do
      route_for(:controller => "messages", :action => "destroy", :board_id => '5', :id => '4').should == { :path => "/boards/5/topics/4/destroy", :method => :post }
    end

    it "routes to #quote" do
      route_for(:controller => "messages", :action => "quote", :board_id => '5', :id => '4').should == "/boards/5/topics/quote/4"
    end

    it "routes to #preview" do
      route_for(:controller => "messages", :action => "preview", :board_id => '5', :id => '4').should == "/boards/5/topics/preview/4"
    end

  end

end
