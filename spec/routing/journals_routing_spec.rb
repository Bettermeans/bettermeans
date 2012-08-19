require 'spec_helper'

describe JournalsController do

  describe "routing" do

    it "routes to #edit" do
      route_for(:controller => "journals", :action => "edit", :id => 'pie').should == "/journals/edit/pie"
    end

    it "routes to #edit_from_dashboard" do
      route_for(:controller => "journals", :action => "edit_from_dashboard", :id => 'pie').should == "/journals/edit_from_dashboard/pie"
    end

  end

end
