require 'spec_helper'

describe HourlyTypesController do

  describe "routing" do

    it "routes to #new" do
      route_for(:controller => "hourly_types", :action => "new", :project_id => "4").should == "/projects/4/hourly_types/new"
    end

    it "routes to #edit" do
      route_for(:controller => "hourly_types", :action => "edit", :project_id => "4", :id => "5").should == "/projects/4/hourly_types/5/edit"
    end

    it "routes to #destroy" do
      route_for(:controller => "hourly_types", :action => "destroy", :project_id => "4", :id => "5").should == { :path => "/projects/4/hourly_types/5/destroy", :method => :post }
    end

  end

end
