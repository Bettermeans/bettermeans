require 'spec_helper'

describe Token, '#before_create' do

  let(:token) { Token.create!({:action => 'test'}) }

  before(:each) { token.user_id = 1 }

  it "should set token value" do
    ActiveSupport::SecureRandom.stub(:hex).and_return('hex')
    token.before_create
    token.value.should == 'hex'
  end

  it "should delete previous matching tokens" do
    previous = Token.create!({:action => 'test delete_previous_tokens', :created_at => 1.hour.ago, :user_id => 2})
    Token.create!({:action => 'test delete_previous_tokens', :user_id => 2})
    Token.find_by_id(previous.id).should == nil
  end

end
