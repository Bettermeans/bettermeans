require 'spec_helper'

describe AttachmentsController do

  describe "routing" do

    it "routes to #create" do
      route_for(:controller => "attachments", :action => "create", :container_id => "5").should == { :path => "/issues/5/attachments/create", :method => :post }
    end

    it "routes to #show" do
      route_for(:controller => "attachments", :action => "show", :id => "5").should == "/attachments/5"
      route_for(:controller => "attachments", :action => "show", :id => "5", :filename => 'five').should == "/attachments/5/five"
    end

    it "routes to #download" do
      route_for(:controller => "attachments", :action => "download", :id => "5", :filename => "my_file").should == { :path => "/attachments/download/5/my_file" }
    end

    it "routes to #destroy" do
      # this doesn't make sense.  Can't pass in an id
      route_for(:controller => "attachments", :action => "destroy").should == { :path => "/attachments/destroy" }
    end

  end

end
