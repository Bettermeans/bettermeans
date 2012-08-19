require 'spec_helper'

describe TodosController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "todos", :action => "index").should == "/todos"
    end

    it "routes to #show" do
      route_for(:controller => "todos", :action => "show", :id => '4').should == "/todos/show/4"
    end

    it "routes to #new" do
      route_for(:controller => "todos", :action => "new").should == "/todos/new"
    end

    it "routes to #edit" do
      route_for(:controller => "todos", :action => "edit", :id => '4').should == "/todos/edit/4"
    end

    it "routes to #create" do
      route_for(:controller => "todos", :action => "create").should == "/todos/create"
    end

    it "routes to #update" do
      route_for(:controller => "todos", :action => "update", :id => '4').should == "/todos/update/4"
    end

    it "routes to #destroy" do
      route_for(:controller => "todos", :action => "destroy", :id => '4').should == "/todos/destroy/4"
    end

  end

end
