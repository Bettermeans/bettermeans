require 'spec_helper'

describe ActivityStreamPreferencesController do
  let(:user) { Factory.create(:user) }
  let(:admin_user) { Factory.create(:user, :admin => true) }
  let!(:activity_stream_pref) { Factory.create(:activity_stream_preference, :user_id => user.id) }

  before(:each) do
    login_as(user)
  end

  describe '#index' do
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

  describe '#create' do
    context 'when user is admin and params[:user_id] is set' do
      before(:each) do
        login_as(admin_user)
      end

      it 'sets @user_id to the selected user_id' do
        post(:create, :user_id => user.id)
        assigns(:user_id).should == user.id.to_s
      end

      it 'redirects to activity_stream_preferences_path with user_id parameter' do
        post(:create, :user_id => user.id)
        response.should redirect_to(activity_stream_preferences_path(:user_id => user.id))
      end
    end

    context 'when params[:user_id] is not set' do
      before(:each) do
        login_as(admin_user)
      end

      it 'sets @user_id to the current user\'s id' do
        post(:create)
        assigns(:user_id).should == admin_user.id
      end

      it 'redirects to activity_stream_preferences_path' do
        post(:create, :user_id => admin_user.id)
        response.should redirect_to(activity_stream_preferences_path)
      end
    end

    context 'when user is not admin' do
      it 'sets @user_id to the current user\'s id' do
        post(:create, :user_id => admin_user.id)
        assigns(:user_id).should == user.id
      end

      it 'redirects to activity_stream_preferences_path' do
        post(:create, :user_id => admin_user.id)
        response.should redirect_to(activity_stream_preferences_path)
      end
    end

    it 'assigns @activity_stream_preferences for the current user' do
      post(:create)
      assigns(:activity_stream_preferences).should == [activity_stream_pref]
    end

    context 'when params[:locations] is set' do
      let(:location) { "#{activity_stream_pref.activity}.#{activity_stream_pref.location}" }
      before(:each) do
        Factory.create(:activity_stream_preference, :user_id => user.id)
      end

      it 'selects only activities for the selected locations' do
        post(:create, :locations => [location])
        assigns(:activities).should == { location => activity_stream_pref }
      end

      it 'destroys preferences with the given location keys' do
        post(:create, :locations => [location])
        id = assigns(:activities).values.first.id
        ActivityStreamPreference.find_by_id(id).should be_nil
      end
    end

    it 'creates an activity stream preference for every combination' do
      post(:create)
      count = ACTIVITY_STREAM_LOCATIONS.size * ACTIVITY_STREAM_ACTIVITIES.size
      preferences = ActivityStreamPreference.find_all_by_user_id(user.id)
      preferences.size.should == count
      preferences.each do |preference|
        ActivityStreamPreference.location_keys.should include preference.location_key
      end
    end

    it 'flashes a success message' do
      flash.stub(:sweep)
      post(:create)
      flash[:success].should =~ /successfully updated/i
    end

    it 'responds to html format' do
      post(:create, :format => 'html')
    end

    it 'resonds to xml format' do
      post(:create, :format => 'xml')
      response.code.should == '200'
    end
  end
end
