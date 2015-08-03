require 'spec_helper'

describe ApplicationController, '#deny_access' do

  class DenyAccessSpecController < ApplicationController
    before_filter :deny_access
  end

  controller_name :deny_access_spec

  it 'renders status 403 when the current user is logged in' do
    login_as(Factory.create(:user))
    get(:index)
    response.status.should == '403 Forbidden'
  end

  it 'redirects to the login page when the current user is not logged in' do
    get(:index)
    back_url = controller.url_for({
      :controller => :deny_access_spec,
      :action => :index,
    })
    response.should redirect_to({
      :controller => :account,
      :action => :login,
      :back_url => back_url,
    })
  end

end
