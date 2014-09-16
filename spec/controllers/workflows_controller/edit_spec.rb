require 'spec_helper'

describe WorkflowsController, '#edit' do

  integrate_views

  let(:workflow) { Factory.create(:workflow) }
  let(:admin_user) { Factory.create(:admin_user) }
  let(:role) { workflow.role }
  let(:tracker) { workflow.tracker }
  let(:valid_params) { { :role_id => role.id, :tracker_id => tracker.id } }

  before(:each) { login_as(admin_user) }

  it 'assigns @role' do
    get(:edit, valid_params)
    assigns(:role).should == role
  end

  it 'assigns @tracker' do
    get(:edit, valid_params)
    assigns(:tracker).should == tracker
  end

  context 'when request is POST' do
    let(:old_status) { Factory.create(:issue_status) }
    let(:new_status) { Factory.create(:issue_status) }
    let(:post_params) do
      valid_params.merge(:issue_status => [[old_status.id, [new_status.id]]])
    end

    it 'destroys all workflows for the given role_id and tracker_id' do
      post(:edit, post_params)
      Workflow.find_by_id(workflow.id).should be_nil
    end

    it 'creates new workflows for all of the given issue statuses' do
      post(:edit, post_params)
      assigns(:role).workflows.count.should == 1
      workflow = assigns(:role).workflows.first
      workflow.tracker.should == tracker
      workflow.old_status.should == old_status
      workflow.new_status.should == new_status
    end

    context 'if the role saves' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        post(:edit, post_params)
        flash[:success].should == I18n.t(:notice_successful_update)
      end

      it 'redirects to the edit action' do
        post(:edit, post_params)
        path_params = {
          :controller => :workflows,
          :action => :edit,
          :role_id => role.id,
          :tracker_id => tracker.id,
        }
        response.should redirect_to(path_params)
      end
    end
  end

  it 'assigns @roles' do
    get(:edit, valid_params)
    assigns(:roles).should == Role.find(:all, :order => 'builtin, position')
  end

  it 'assigns @trackers' do
    get(:edit, valid_params)
    assigns(:trackers).should == Tracker.find(:all, :order => 'position')
  end

  it 'assigns @used_statuses_only' do
    get(:edit, valid_params)
    assigns(:used_statuses_only).should == true
  end

  context 'when @used_statuses_only and tracker has issue statuses' do
    it 'assigns @statuses as the issue statuses associated with the tracker' do
      get(:edit, valid_params.merge(:used_statuses_only => '1'))
      assigns(:statuses).should == tracker.issue_statuses
    end
  end

  context 'when not @used_statuses_only' do
    it 'assigns @statuses as all issue statuses' do
      get(:edit, valid_params.merge(:used_statuses_only => '0'))
      assigns(:statuses).should == IssueStatus.find(:all, :order => 'position')
    end
  end

end
