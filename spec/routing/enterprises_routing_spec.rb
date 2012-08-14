require 'spec_helper'

describe EnterprisesController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "enterprises", :action => "index").should == "/enterprises"
    end

    it "routes to #show" do
      route_for(:controller => "enterprises", :action => "show", :id => '5').should == "/enterprises/show/5"
    end

    it "routes to #new" do
      route_for(:controller => "enterprises", :action => "new").should == "/enterprises/new"
    end

    it "routes to #edit" do
      route_for(:controller => "enterprises", :action => "edit", :id => '5').should == "/enterprises/edit/5"
    end

    it "routes to #create" do
      route_for(:controller => "enterprises", :action => "create").should == "/enterprises/create"
    end

    it "routes to #activate" do
      route_for(:controller => "enterprises", :action => "activate").should == "/enterprises/activate"
    end

  end

end
