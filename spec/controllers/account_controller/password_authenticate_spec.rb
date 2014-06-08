require 'spec_helper'

# private method, no state
describe AccountController, '#password_authentication' do

  let(:user) { Factory.create(:user) }
  before :each do
    controller.stub(:render)
  end

  it "tries to login the user" do
    User.should_receive(:authenticate).with('bill', 'bill_password')
    controller.stub(:params).and_return({ :username => 'bill', :password => 'bill_password' })
    controller.send(:password_authentication, nil)
  end

  context "when the user does not login properly" do
    it "goes through the invalid credentials flow" do
      User.stub(:authenticate)
      controller.should_receive(:render).with(:layout => 'static')
      controller.send(:password_authentication, nil)
    end
  end

  context "when the user is a new record" do
    it "goes through the onthefly creation failed flow" do
      user.login = 'bill'
      user.auth_source_id = 15
      user.stub(:new_record?).and_return(true)
      User.stub(:authenticate).and_return(user)
      controller.should_receive(:onthefly_creation_failed).with(user, { :login => 'bill', :auth_source_id => 15 })
      controller.send(:password_authentication, nil)
    end
  end

  context "when the user is not active" do
    it "goes through the inactive_user flow" do
      user.stub(:active?).and_return(false)
      User.stub(:authenticate).and_return(user)
      controller.should_receive(:inactive_user)
      controller.send(:password_authentication, nil)
    end
  end

  context "otherwise" do
    context "when the user is active" do
      it "goes through the successful_authentication flow" do
        user.stub(:active?).and_return(true)
        User.stub(:authenticate).and_return(user)
        controller.should_receive(:successful_authentication).with(user, 'token')
        controller.send(:password_authentication, 'token')
        controller.should_receive(:successful_authentication).with(user, nil)
        controller.send(:password_authentication, nil)
      end
    end
  end

end
