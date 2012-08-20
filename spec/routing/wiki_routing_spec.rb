require 'spec_helper'

describe WikiController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "wiki", :action => "index", :id => '5', :page => 'stuff').should == "projects/5/wiki/stuff"
    end

    it "routes to #edit" do
      route_for(:controller => "wiki", :action => "edit", :id => '5', :page => 'stuff').should == "/projects/5/wiki/stuff/edit"
      route_for(:controller => "wiki", :action => "edit", :id => '5', :page => 'stuff').should == { :path => "/projects/5/wiki/stuff/edit", :method => :post }
    end

    it "routes to #rename" do
      route_for(:controller => "wiki", :action => "rename", :id => '5', :page => 'stuff').should == "/projects/5/wiki/stuff/rename"
      route_for(:controller => "wiki", :action => "rename", :id => '5', :page => 'stuff').should == { :path => "/projects/5/wiki/stuff/rename", :method => :post }
    end

    it "routes to #protect" do
      route_for(:controller => "wiki", :action => "protect", :id => '5', :page => 'stuff').should == { :path => "/projects/5/wiki/stuff/protect", :method => :post }
    end

    it "routes to #history" do
      route_for(:controller => "wiki", :action => "history", :id => '5', :page => 'stuff').should == "/projects/5/wiki/stuff/history"
    end

    it "routes to #diff" do
      route_for(:controller => "wiki", :action => "diff", :id => '5', :page => 'stuff', :version => '2', :version_from => '3').should == "/projects/5/wiki/stuff/diff/2/vs/3"
    end

    it "routes to #annotate" do
      route_for(:controller => "wiki", :action => "annotate", :id => '5', :page => 'stuff', :version => '2').should == "/projects/5/wiki/stuff/annotate/2"
    end

    it "routes to #destroy" do
      route_for(:controller => "wiki", :action => "destroy", :id => '5', :page => 'stuff').should == { :path => "/projects/5/wiki/stuff/destroy", :method => :post }
    end

    it "routes to #special" do
      route_for(:controller => "wiki", :action => "special", :id => '5', :page => 'page_index').should == "/projects/5/wiki/page_index"
      route_for(:controller => "wiki", :action => "special", :id => '5', :page => 'date_index').should == "/projects/5/wiki/date_index"
      route_for(:controller => "wiki", :action => "special", :id => '5', :page => 'export').should == "/projects/5/wiki/export"
    end

    it "routes to #preview" do
      route_for(:controller => "wiki", :action => "preview", :id => '5', :page => 'stuff').should == { :path => "/projects/5/wiki/stuff/preview", :method => :post }
    end

    it "routes to #add_attachment" do
      route_for(:controller => "wiki", :action => "add_attachment", :id => '5', :page => 'stuff').should == "/wiki/5/stuff/add_attachment"
    end

  end

end
