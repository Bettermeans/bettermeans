require 'spec_helper'

describe ApplicationController, '#check_if_login_required' do

  let(:user) { Factory.create(:user) }

  integrate_views(false)

  class CheckIfLoginRequiredSpecController < ApplicationController
    def index
      @got_in = true
    end
  end

  controller_name :check_if_login_required_spec

  it 'succeeds if the current user is already logged in' do
    login_as(user)
    get(:index)
    assigns(:got_in).should be true
  end

  it 'blocks when Setting.require_login?' do
    Setting.stub(:login_required?).and_return(true)
    get(:index)
    assigns(:got_in).should be nil
  end

  it 'succeeds when not Setting.require_login?' do
    Setting.stub(:login_required?).and_return(false)
    get(:index)
    assigns(:got_in).should be true
  end

end
