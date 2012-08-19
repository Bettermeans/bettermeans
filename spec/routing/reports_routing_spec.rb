require 'spec_helper'

describe ReportsController do

  describe "routing" do

    it "routes to #issue_report" do
      route_for(:controller => "reports", :action => "issue_report", :id => '5').should == "projects/5/issues/report"
      route_for(:controller => "reports", :action => "issue_report", :id => '5', :detail => 'stuff').should == "projects/5/issues/report/stuff"
    end

  end

end
