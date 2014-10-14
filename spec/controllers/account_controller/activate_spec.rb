require 'spec_helper'

describe AccountController, '#activate' do

  context 'if self_registration is not set' do
    it 'redirects to home_url' do
      user = Factory.create(:user, :status => User::STATUS_REGISTERED)
      token = Token.create(:user => user, :action => 'register')
      Setting.stub(:self_registration?).and_return(false)
      get(:activate, :token => token.value)
      response.should redirect_to(home_url)
    end
  end

  context 'if params[:token] is not present' do
    it 'redirects to home_url' do
      user = Factory.create(:user, :status => User::STATUS_REGISTERED)
      token = Token.create(:user => user, :action => 'register')
      Setting.stub(:self_registration?).and_return(true)
      get(:activate)
      response.should redirect_to(home_url)
    end
  end

  context 'if the token is not found' do
    it 'redirects to home_url' do
      Setting.stub(:self_registration?).and_return(true)
      get(:activate, :token => 'blah')
      response.should redirect_to(home_url)
    end
  end

  context 'if the token is found but expired' do
    it 'redirects to home_url' do
      Setting.stub(:self_registration?).and_return(true)
      user = Factory.create(:user, :status => User::STATUS_REGISTERED)
      token = Token.create(:user => user, :action => 'register')
      token.stub(:expired?).and_return(true)
      Token.should_receive(:find_by_action_and_value).
        with('register', token.value).
        and_return(token)
      get(:activate, :token => token.value)
      response.should redirect_to(home_url)
    end
  end

  context 'if the user is not registered' do
    it 'redirects to home_url' do
      Setting.stub(:self_registration?).and_return(true)
      user = Factory.create(:user, :status => User::STATUS_ACTIVE)
      token = Token.create(:user => user, :action => 'register')
      get(:activate, :token => token.value)
      response.should redirect_to(home_url)
    end
  end

  context 'if the user is valid' do
    let(:user) { Factory.create(:user, :status => User::STATUS_REGISTERED) }
    let(:token) { Token.create(:user => user, :action => 'register') }

    before :each do
      Setting.stub(:self_registration?).and_return(true)
    end

    it 'changes the status of the user to active' do
      get(:activate, :token => token.value)
      user.reload.status.should == User::STATUS_ACTIVE
    end

    it 'destroys the token' do
      get(:activate, :token => token.value)
      Token.find_by_id(token.id).should_not be
    end

    it 'logs in the user' do
      get(:activate, :token => token.value)
      controller.current_user.should == user
    end

    it 'redirects to welcome/index' do
      get(:activate, :token => token.value)
      response.should redirect_to(:controller => :welcome, :action => :index)
    end

    it 'redirects back given a back_url' do
      back_url = 'test.host/what/the/heck'
      get(:activate, :token => token.value, :back_url => back_url)
      response.should redirect_to(back_url)
    end
  end

  context 'if the user is invalid' do
    let(:user) { Factory.create(:user, :status => User::STATUS_REGISTERED) }
    let(:token) { Token.create(:user => user, :action => 'register') }

    before :each do
      Setting.stub(:self_registration?).and_return(true)
      user.stub(:save).and_return(false)
      token.stub(:user).and_return(user)
      Token.stub(:find_by_action_and_value).and_return(token)
      get(:activate, :token => token.value)
    end

    it 'renders the login page' do
      response.should render_template('login')
    end

    it 'renders the static layout' do
      response.layout.should == 'layouts/static'
    end
  end

end
