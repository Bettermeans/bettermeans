require 'spec_helper'

describe DocumentsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "documents", :action => "index", :project_id => "5").should == "/projects/5/documents"
    end

    it "routes to #show" do
      route_for(:controller => "documents", :action => "show", :id => "5").should == "/documents/5"
    end

    it "routes to #new" do
      route_for(:controller => "documents", :action => "new", :project_id => "5").should == "/projects/5/documents/new"
    end

    it "routes to #edit" do
      route_for(:controller => "documents", :action => "edit", :id => "5").should == "/documents/5/edit"
    end

    it "routes to #destroy" do
      route_for(:controller => "documents", :action => "destroy", :id => "5").should == {:path => "/documents/5/destroy", :method => :post}
    end

    it "routes to #add_attachment" do
      route_for(:controller => "documents", :action => "add_attachment", :id => "5").should == "/documents/add_attachment/5"
    end

  end

end
