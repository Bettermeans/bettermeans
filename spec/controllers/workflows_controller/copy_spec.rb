require 'spec_helper'

describe WorkflowsController, '#copy' do

  let(:admin_user) { Factory.create(:user, :admin => true) }
  let(:tracker) { Factory.create(:tracker) }
  let(:role) { Factory.create(:role) }
  let(:trackers) { Tracker.all.sample(2) }
  let(:roles) { Role.all.sample(2) }

  before(:each) { login_as(admin_user) }

  it 'assigns @trackers' do
    get(:copy)
    assigns(:trackers).should == Tracker.find(:all, :order => 'position')
  end

  it 'assigns @roles' do
    get(:copy)
    assigns(:roles).should == Role.find(:all, :order => 'builtin, position')
  end

  context 'when params[:source_tracker_id] is blank' do
    it 'assigns @source_tracker to nil' do
      get(:copy)
      assigns(:source_tracker).should be_nil
    end
  end

  context 'when params[:source_tracker_id] is "any"' do
    it 'assigns @source_tracker to nil' do
      get(:copy, :source_tracker_id => 'any')
      assigns(:source_tracker).should be_nil
    end
  end

  context 'when params[:source_tracker_id]' do
    it 'assigns @source_trackers to the tracker' do
      get(:copy, :source_tracker_id => tracker.id)
      assigns(:source_tracker).should == tracker
    end
  end

  context 'when params[:source_role_id] is blank' do
    it 'assigns @source_role to nil' do
      get(:copy)
      assigns(:source_role).should be_nil
    end
  end

  context 'when params[:source_role_id] is "any"' do
    it 'assigns @source_role to nil' do
      get(:copy, :source_role_id => 'any')
      assigns(:source_role).should be_nil
    end
  end

  context 'when params[:source_role_id]' do
    it 'assigns @source_roles to the role' do
      get(:copy, :source_role_id => role.id)
      assigns(:source_role).should == role
    end
  end

  it 'assigns @target_trackers when params[:target_tracker_ids] is present' do
    get(:copy, :target_tracker_ids => trackers.map(&:id))
    assigns(:target_trackers).sort.should == trackers.sort
  end

  it 'assigns @target_roles when params[:target_roles] is present' do
    get(:copy, :target_role_ids => roles.map(&:id))
    assigns(:target_roles).sort.should == roles.sort
  end

  context 'when request is POST' do
    let(:post_params) do
      {
        :source_tracker_id => tracker.id,
        :source_role_id => role.id,
        :target_tracker_ids => trackers.map(&:id),
        :target_role_ids => roles.map(&:id),
      }
    end

    before(:each) { flash.stub(:sweep) }

    context 'when params[:source_tracker_id] is blank' do
      it 'flashes an error' do
        post_params.delete(:source_tracker_id)
        post(:copy, post_params)
        flash[:error].should == I18n.t(:error_workflow_copy_source)
      end
    end

    context 'when params[:source_role_id] is blank' do
      it 'flashes an error' do
        post_params.delete(:source_role_id)
        post(:copy, post_params)
        flash[:error].should == I18n.t(:error_workflow_copy_source)
      end
    end

    context 'when @source_tracker and @source_role are nil' do
      it 'flashes an error' do
        post_params.merge!(:source_tracker_id => 500, :source_role_id => 500)
        post(:copy, post_params)
        flash[:error].should == I18n.t(:error_workflow_copy_source)
      end
    end

    context 'when @target_trackers is nil' do
      it 'flashes an error' do
        post_params.delete(:target_tracker_ids)
        post(:copy, post_params)
        flash[:error].should == I18n.t(:error_workflow_copy_target)
      end
    end

    context 'when @target_roles is nil' do
      it 'flashes an error' do
        post_params.delete(:target_role_ids)
        post(:copy, post_params)
        flash[:error].should == I18n.t(:error_workflow_copy_target)
      end
    end

    it 'copies workflows' do
      Workflow.should_receive(:copy) do |arg1, arg2, arg3, arg4|
        arg1.should == tracker
        arg2.should == role
        arg3.sort.should == trackers.sort
        arg4.sort.should == roles.sort
      end
      post(:copy, post_params)
    end

    it 'flashes a success message' do
      flash.stub(:sweep)
      post(:copy, post_params)
      flash[:success].should == I18n.t(:notice_successful_update)
    end

    it 'redirects to the copy action' do
      post(:copy, post_params)
      path_params = {
        :controller => :workflows,
        :action => :copy,
        :source_tracker_id => tracker.id,
        :source_role_id => role.id,
      }
      response.should redirect_to(path_params)
    end
  end

end
