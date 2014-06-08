require 'spec_helper'

describe AccountController, '#cancel' do
  let(:user) { Factory.create(:user, :mail => 'bob@bob.com') }

  before :each do
    User.stub(:current).and_return(user)
  end

  it "cancels the current user's account" do
    get(:cancel)
    user.reload.should be_canceled
  end

  it "renders an account canceled message" do
    get(:cancel)
    response.should render_template ''
    response.session[:flash][:notice].should =~ /canceled/
  end
end
