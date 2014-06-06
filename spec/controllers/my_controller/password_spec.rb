require 'spec_helper'

describe MyController, '#password' do

  let(:user) { Factory.create(:user, :password => 'foobar') }

  before(:each) do
    flash.stub(:sweep)
    login_as(user)
  end

  context 'when the current user has an auth source' do
    before(:each) do
      user.update_attributes!(:auth_source => Factory.create(:auth_source))
      get(:password)
    end

    it 'flashes an error' do
      flash.now[:error].should == I18n.t(:notice_can_t_change_password)
    end

    it 'redirects to the "account" action' do
      response.should redirect_to(:controller => :my, :action => :account)
    end
  end

  context 'when the request is a post' do
    context 'when the password matches' do
      context 'when the user is valid' do
        before(:each) do
          post(:password, {
            :password => 'foobar',
            :new_password => 'bazblah',
            :new_password_confirmation => 'bazblah',
          })
        end

        it 'changes the user' do
          user.reload.authenticate('foobar').should == false
          user.authenticate('bazblah').should == true
        end

        it 'flashes a success message' do
          flash.now[:success].should == I18n.t(:notice_account_password_updated)
        end

        it 'redirects to the "account" action' do
          response.should redirect_to(:controller => :my, :action => :account)
        end
      end
    end

    context 'when the password does not match' do
      before(:each) do
        post(:password, {
          :password => 'nogood',
          :new_password => 'bazblah',
          :new_password_confirmation => 'bazblah',
        })
      end

      it 'does not change the user' do
        user.reload.authenticate('foobar').should == true
        user.authenticate('bazblah').should == false
      end

      it 'flashes an error' do
        flash[:error].should == I18n.t(:notice_account_wrong_password)
      end
    end

    context 'when the password confirmation does not match' do
      before(:each) do
        post(:password, {
          :password => 'foobar',
          :new_password => 'nogood',
          :new_password_confirmation => 'bazblah',
        })
      end

      it 'does not change the user' do
        user.reload.authenticate('foobar').should == true
        user.authenticate('bazblah').should == false
      end
    end
  end

end
