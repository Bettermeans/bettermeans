require 'spec_helper'

describe ActivityStreamPreferencesController, '#index' do

  integrate_views

  let(:user) { Factory.create(:user) }
  let(:admin_user) { Factory.create(:user, :admin => true) }
  let!(:activity_stream_pref) { Factory.create(:activity_stream_preference, :user_id => user.id) }

  before(:each) do
    login_as(user)
  end

  context 'when user is admin and params[:user_id] is set' do
    before(:each) do
      login_as(admin_user)
    end

    it 'sets @user_id to the selected user_id' do
      get(:index, :user_id => user.id)
      assigns(:user_id).should == user.id.to_s
    end
  end

  context 'when params[:user_id] is not set' do
    before(:each) do
      login_as(admin_user)
    end

    it 'sets @user_id to the current user\'s id' do
      get(:index)
      assigns(:user_id).should == admin_user.id
    end
  end

  context 'when user is not admin' do
    it 'sets @user_id to the current user\'s id' do
      get(:index, :user_id => admin_user.id)
      assigns(:user_id).should == user.id
    end
  end

  it 'assigns @activity_stream_preferences for the current user' do
    get(:index)
    assigns(:activity_stream_preferences).should == [activity_stream_pref]
  end

  it 'assigns @activities based on activity stream preferences' do
    get(:index)
    assigns(:activities).should == { "#{activity_stream_pref.activity}.#{activity_stream_pref.location}" => activity_stream_pref }
  end

  it 'assigns @user' do
    get(:index)
    assigns(:user).should == user
  end

  context 'when the user\'s activity stream token is blank' do
    it 'assigns a new token based on the current time' do
      time = Time.now
      Time.stub(:now).and_return(time)
      controller.should_receive(:rand).and_return(*(1..time.to_s.length).to_a.reverse)
      Digest::SHA1.should_receive(:hexdigest).with(time.to_s.reverse).and_return('blah')
      user.activity_stream_token.should be_nil
      get(:index)
      user.reload.activity_stream_token.should_not be_nil
    end

    context 'if @user is the current user' do
      it 'reloads the current user' do
        controller.stub(:current_user).and_return(user)
        user.should_receive(:reload)
        get(:index)
      end
    end
  end

  context 'when the user\'s activity stream token is not blank' do
    it 'does not reassign the token' do
      user.update_attributes(:activity_stream_token => 'boogers')
      get(:index)
      user.reload.activity_stream_token.should == 'boogers'
    end
  end

  it 'responds to html format' do
    get(:index, :format => 'html')
    response.should render_template('activity_stream_preferences/index')
  end

  it 'responds to xml format' do
    get(:index, :format => 'xml')
    response.body.should == [activity_stream_pref].to_xml
  end

end
