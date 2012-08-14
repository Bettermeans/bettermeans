require 'spec_helper'

describe HelpController do

  describe "routing" do

    it "routes to #show" do
      route_for(:controller => "help", :action => "show", :id => "show").should == "/help/show"
    end

  end

end
