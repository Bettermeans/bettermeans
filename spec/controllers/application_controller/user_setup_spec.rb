require 'spec_helper'

describe ApplicationController, '#user_setup' do

  integrate_views(false)

  class UserSetupSpecController < ApplicationController
    def index
    end
  end

  controller_name :user_setup_spec

  let(:user) { Factory.create(:user) }

  it 'checks the setting cache' do
    Setting.should_receive(:check_cache)
    get(:index)
  end

  it 'sets the current user' do
    session[:user_id] = user.id
    get(:index)
    controller.current_user.should == user
  end

end
