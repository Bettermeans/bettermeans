require 'spec_helper'

describe CommentsController do

  describe "routing" do

    it "routes to #index" do
      route_for(:controller => "comments", :action => "index").should == "/comments"
    end

    it "routes to #create" do
      route_for(:controller => "comments", :action => "create").should == "/comments/create"
    end

  end

end
