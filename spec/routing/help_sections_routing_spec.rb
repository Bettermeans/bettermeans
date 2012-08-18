require 'spec_helper'

describe HelpSectionsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "help_sections", :action => "index").should == "/help_sections"
    end

    it "routes to #show" do
      route_for(:controller => "help_sections", :action => "show", :id => "5").should == "/help_sections/5"
    end

    it "routes to #dont_show" do
      route_for(:controller => "help_sections", :action => "dont_show", :id => '5').should == "/help_sections/dont_show/5"
    end

    it "routes to #new" do
      route_for(:controller => "help_sections", :action => "new").should == "/help_sections/new"
    end

    it "routes to #edit" do
      route_for(:controller => "help_sections", :action => "edit", :id => "5").should == "/help_sections/5/edit"
    end

    it "routes to #create" do
      route_for(:controller => "help_sections", :action => "create").should == { :path => "/help_sections", :method => :post }
    end

    it "routes to #update" do
      route_for(:controller => "help_sections", :action => "update", :id => '5').should == { :path => "/help_sections/5", :method => :put }
    end

    it "routes to #destroy" do
      route_for(:controller => "help_sections", :action => "destroy", :id => '5').should == { :path => "/help_sections/5", :method => :delete }
    end

  end

end
