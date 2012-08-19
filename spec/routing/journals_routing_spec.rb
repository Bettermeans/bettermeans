require 'spec_helper'

describe JournalsController do

  describe "routing" do

    it "routes to #edit" do
      route_for(:controller => "journals", :action => "edit", :id => '5').should == "/journals/edit/5"
    end

    it "routes to #edit_from_dashboard" do
      route_for(:controller => "journals", :action => "edit_from_dashboard", :id => '5').should == "/journals/edit_from_dashboard/5"
    end

  end

end
