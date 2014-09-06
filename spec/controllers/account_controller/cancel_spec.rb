require 'spec_helper'

describe AccountController, '#cancel' do

  integrate_views

  let(:user) { Factory.create(:user, :mail => 'bob@bob.com') }

  before :each do
    User.stub(:current).and_return(user)
  end

  it "cancels the current user's account" do
    get(:cancel)
    user.reload.canceled?.should be true
  end

  it "renders an account canceled message" do
    get(:cancel)
    response.should render_template ''
    response.session[:flash][:notice].should =~ /canceled/
  end

end
