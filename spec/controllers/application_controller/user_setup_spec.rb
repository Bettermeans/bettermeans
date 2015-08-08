require 'spec_helper'

describe ApplicationController, '#user_setup' do

  integrate_views(false)

  class UserSetupSpecController < ApplicationController
    def index
      @user = current_user
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

  context 'when there is an autologin cookie and the setting is enabled' do
    context 'when a user is found' do
      let(:token) { Token.create!(:action => 'autologin', :user => user) }
      before(:each) do
        # tests seem to cast the request cookies to have string keys
        # request.cookies[:autologin] = 'foo'
        controller.stub(:cookies).and_return({ :autologin => token.value })
      end

      it 'sets the user_id in the session' do
        get(:index)
        controller.current_user.should == user
      end

      it 'tracks the login for the user' do
        session[:client_ip] = 'blah'
        Track.should_receive(:log).with(Track::LOGIN, 'blah')
        get(:index)
      end
    end

    it 'does not track the login when user is not found' do
      controller.stub(:cookies).and_return({ :autologin => 'foo' })
      Track.should_not_receive(:log)
      get(:index)
    end
  end

  it 'does not try to auto login if setting is disabled' do
    controller.stub(:cookies).and_return({ :autologin => 'foo' })
    User.should_not_receive(:try_to_autologin)
    Setting['autologin'] = 0
    get(:index)
  end

  context 'when rest api is enabled' do
    before(:each) do
      Setting['rest_api_enabled'] = 1
      controller.class.accept_key_auth(:index)
    end

    it 'sets the user to anonymous when the format is not ajax' do
      get(:index)
      controller.current_user.should == AnonymousUser.first
    end

    it 'sets the user to anonymous when not an authorized ajax action' do
      controller.class.accept_key_auth
      get(:index, :format => 'xml', :key => user.api_key)
      controller.current_user.should == AnonymousUser.first
    end

    context 'when action is ajax and action is authorized' do
      it 'finds the user by api key when key is given' do
        get(:index, :format => 'xml', :key => user.api_key)
        controller.current_user.should == user
        get(:index, :format => 'json', :key => user.api_key)
        controller.current_user.should == user
      end

      it 'authenticates the user with http basic when key is not given' do
        controller.should_receive(:authenticate_with_http_basic).
          and_yield(user.login, user.password)
        get(:index, :format => 'xml')
        controller.current_user.should == user
      end

      it 'tries the username as an api key when authentication fails' do
        controller.should_receive(:authenticate_with_http_basic).
          and_yield(user.api_key, 'foo')
        get(:index, :format => 'xml')
        controller.current_user.should == user
      end
    end
  end

  it 'sets the user to anonymous when rest api is disabled' do
    Setting['rest_api_enabled'] = 0
    controller.class.accept_key_auth(:index)
    get(:index, :format => 'xml', :key => user.api_key)
    controller.current_user.should == AnonymousUser.first
  end

end
