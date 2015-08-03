require 'spec_helper'

describe ApplicationController, '#check_project_privacy' do

  let(:user) { Factory.create(:user) }
  let(:admin_user) { Factory.create(:admin_user) }
  let(:project) { Factory.create(:project, :is_public => false) }

  integrate_views(false)

  class CheckProjectPrivacySpecController < ApplicationController

    def show
      @project = Project.find_by_id(params[:id])
      @result = check_project_privacy
    end

  end

  controller_name :check_project_privacy_spec

  context 'when there is a project and it is active' do
    it 'returns true when the project is public' do
      project.update_attributes!(:is_public => true)
      get(:show, :id => project.id)
      assigns(:result).should be true
    end

    it 'returns true when the current user is allowed to see the project' do
      login_as(user)
      user.add_as_member(project)
      get(:show, :id => project.id)
      assigns(:result).should be true
    end

    it 'returns true when the current user is admin' do
      login_as(admin_user)
      get(:show, :id => project.id)
      assigns(:result).should be true
    end

    it 'renders a 403 error when the current user cannot see the project' do
      login_as(user)
      get(:show, :id => project.id)
      response.status.should == '403 Forbidden'
    end

    it 'redirects to the login page when the user is not logged in' do
      get(:show, :id => project.id)
      back_url = controller.url_for({
        :controller => :check_project_privacy_spec,
        :action => :show,
      })
      response.should redirect_to({
        :controller => :account,
        :action => :login,
        :back_url => back_url,
      })
    end
  end

  context 'when there is no project' do
    before(:each) do
      get(:show, :id => 5_000_000)
    end

    it 'sets the project to nil' do
      assigns(:project).should be nil
    end

    it 'renders a 404 error' do
      response.status.should == '404 Not Found'
    end

    it 'returns false' do
      assigns(:result).should be false
    end
  end

  context 'when the project is not active' do
    before(:each) do
      project.lock
      get(:show, :id => project.id)
    end

    it 'sets the project to nil' do
      assigns(:project).should be nil
    end

    it 'renders a 404 error' do
      response.status.should == '404 Not Found'
    end

    it 'returns false' do
      assigns(:result).should be false
    end
  end

end
