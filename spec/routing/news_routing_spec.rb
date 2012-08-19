require 'spec_helper'

describe NewsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "news", :action => "index").should == "/news"
      route_for(:controller => "news", :action => "index", :project_id => '5').should == "projects/5/news"
    end

    it "routes to #show" do
      route_for(:controller => "news", :action => "show", :id => '5').should == "/news/5"
    end

    it "routes to #new" do
      route_for(:controller => "news", :action => "new", :project_id => '5').should == "/projects/5/news/new"
      params_from(:post, "/projects/5/news").should == { :controller => "news", :action => "new", :project_id => '5' }
    end

    it "routes to #edit" do
      route_for(:controller => "news", :action => "edit", :id => '5').should == "/news/5/edit"
      route_for(:controller => "news", :action => "edit", :id => '5').should == { :path => "/news/5/edit", :method => :post }
    end

    it "routes to #add_comment" do
      route_for(:controller => "news", :action => "add_comment", :id => '5').should == "/news/add_comment/5"
    end

    it "routes to #destroy_comment" do
      route_for(:controller => "news", :action => "destroy_comment", :id => '5').should == "/news/destroy_comment/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "news", :action => "destroy", :id => '5').should == { :path => "/news/5/destroy", :method => :post }
    end

    it "routes to #preview" do
      route_for(:controller => "news", :action => "preview", :id => '5').should == "/news/preview/5"
    end

  end

end
