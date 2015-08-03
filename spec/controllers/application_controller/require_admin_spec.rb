require 'spec_helper'

describe ApplicationController, '#require_admin' do

  let(:user) { Factory.create(:user) }

  integrate_views(false)

  class RequireAdminSpecController < ApplicationController
    before_filter :require_admin

    def index
      @made_it = true
    end
  end

  controller_name :require_admin_spec

  it 'returns right away when user is not logged in' do
    get(:index)
    assigns(:made_it).should be nil
  end

  context 'when logged in user is not admin' do
    before(:each) do
      login_as(user)
      get(:index)
    end

    it 'renders a 403 error' do
      response.status.should == '403 Forbidden'
    end

    it 'does not get to the controller action' do
      assigns(:made_it).should be nil
    end
  end

  it 'goes to the controller action when the user is admin' do
    login_as(Factory.create(:admin_user))
    get(:index)
    assigns(:made_it).should be true
  end

end
