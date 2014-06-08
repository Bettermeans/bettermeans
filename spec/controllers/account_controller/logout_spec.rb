require 'spec_helper'

describe AccountController, '#logout' do
  let(:user) { Factory.create(:user) }

  before :each do
    controller.logged_user = user
    @token = Token.create(:user => user, :action => 'autologin')
    request.cookies["autologin"] = @token.value
    get(:logout)
  end

  it 'deletes the autologin cookie' do
    # for some reason both request.cookies and response.cookies are nil regardless
    controller.send(:cookies)[:autologin].should_not be
  end

  it 'deletes all autologin tokens for the given user' do
    Token.find_by_id(@token.id).should_not be
  end

  it 'sets the currently logged in user to nil' do
    controller.current_user.should be_anonymous
  end

  it 'redirects to the homepage' do
    response.should redirect_to home_url
  end
end
