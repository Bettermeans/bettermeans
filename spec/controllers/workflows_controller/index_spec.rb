require 'spec_helper'

describe WorkflowsController, '#index' do

  integrate_views

  let!(:workflow_1) { Factory.create(:workflow) }
  let!(:workflow_2) { Factory.create(:workflow) }
  let(:admin_user) { Factory.create(:admin_user) }

  before(:each) { login_as(admin_user) }

  it 'assigns @workflows_counts' do
    get(:index)
    flattened_counts = assigns(:workflow_counts).flatten
    (Tracker.all - flattened_counts).should == []
    (Role.all - flattened_counts).should == []
    flattened_counts.count { |elem| elem == 1 }.should == 2
    flattened_counts.count { |elem| elem == 0 }.should == (Tracker.count * Role.count - 2)
  end

end
