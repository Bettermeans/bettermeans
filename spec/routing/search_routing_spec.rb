require 'spec_helper'

describe SearchController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "search", :action => "index").should == "/search"
    end

  end

end
