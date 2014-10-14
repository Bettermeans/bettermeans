require 'spec_helper'

describe InvitationsController, '#accept' do

  let(:invitation) { Factory.create(:invitation) }
  let(:user) { Factory.create(:user) }
  let(:valid_params) { { :id => invitation.id, :token => invitation.token } }

  it 'assigns @invitation' do
    get(:accept, valid_params)
    assigns(:invitation).should == invitation
  end

  context 'when the token does not match the invitation' do
    let(:invalid_params) { valid_params.merge(:token => 'foo') }

    it 'flashes an error' do
      get(:accept, invalid_params)
      flash[:error].should == I18n.t(:error_old_invite)
    end

    it 'redirects to the project for the invitation' do
      get(:accept, invalid_params)
      response.should redirect_to(invitation.project)
    end
  end

  it 'sets @user when the invitation has a new_mail' do
    user = Factory.create(:user, :mail => 'b@b.com')
    invitation.update_attributes!(:new_mail => 'b@b.com')
    get(:accept, valid_params)
    assigns(:user).should == user
  end

  it 'sets @user when the invitation has no new_mail' do
    user = Factory.create(:user, :mail => 'b@b.com')
    invitation.update_attributes!(:mail => 'b@b.com')
    get(:accept, valid_params)
    assigns(:user).should == user
  end

  context 'when user is found' do
    let(:invitation) { Factory.create(:invitation, :mail => user.mail) }

    it 'logs in the user' do
      get(:accept, valid_params)
      session[:user_id].should == user.id
    end

    it 'tracks the login' do
      Track.should_receive(:log).with(Track::LOGIN, '0.0.0.0')
      get(:accept, valid_params)
    end

    it 'accepts the invitation' do
      get(:accept, valid_params)
      invitation.reload.status_name.should == 'Accepted'
    end

    it 'flashes a success message' do
      get(:accept, valid_params)
      flash[:success].should match(/invitation accepted/i)
    end

    it 'redirects to the project page' do
      get(:accept, valid_params)
      response.should redirect_to(invitation.project)
    end
  end

  context 'when user is not found' do
    it 'sets the token in the session' do
      get(:accept, valid_params)
      session[:invitation].should == invitation.token
    end

    it 'redirects to the register page' do
      get(:accept, valid_params)
      path_params = {
        :controller => :account,
        :action => :register,
        :invitation_token => invitation.token,
      }
      response.should redirect_to(path_params)
    end
  end

end
