require 'spec_helper'

describe RetrosController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "retros", :action => "index", :project_id => '5').should == "/projects/5/retros"
    end

    it "routes to #index_json" do
      route_for(:controller => "retros", :action => "index_json", :project_id => '5').should == "/projects/5/retros/index_json"
    end

    it "routes to #dashdata" do
      route_for(:controller => "retros", :action => "dashdata", :project_id => '5', :id => '4').should == "/projects/5/retros/4/dashdata"
    end

    it "routes to #show" do
      route_for(:controller => "retros", :action => "show", :project_id => '5', :id => '4').should == "/projects/5/retros/4/show"
      params_from(:get, "/projects/5/retros/4").should == { :controller => "retros", :action => "show", :id => '4', :project_id => '5' }
    end

    it "routes to #new" do
      route_for(:controller => "retros", :action => "new", :project_id => '5').should == "/projects/5/retros/new"
      params_from(:post, "/projects/5/retros").should == { :controller => "retros", :action => "new", :project_id => '5' }
    end

    it "routes to #edit" do
      route_for(:controller => "retros", :action => "edit", :project_id => '5', :id => '4').should == "/projects/5/retros/4/edit"
      route_for(:controller => "retros", :action => "edit", :project_id => '5', :id => '4').should == { :path => "/projects/5/retros/4/edit", :method => :post }
    end

    it "routes to #create" do
      route_for(:controller => "retros", :action => "create", :id => '5').should == "/retros/create/5"
    end

    it "routes to #update" do
      route_for(:controller => "retros", :action => "update", :id => '5').should == "/retros/update/5"
    end

    it "routes to #destroy" do
      route_for(:controller => "retros", :action => "destroy", :id => '5').should == "/retros/destroy/5"
      route_for(:controller => "retros", :action => "destroy", :project_id => '5', :id => '4').should == { :path => "/projects/5/retros/4/destroy", :method => :post }
    end

  end

end
