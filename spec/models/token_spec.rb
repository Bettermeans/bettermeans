require 'spec_helper'

describe Token do
  let(:token) { Token.new }

  before(:each) { token.user_id = 1 }

  describe '#before_create' do
    it "should call Token.generate_token_value" do
      Token.should_receive(:generate_token_value)
      token.before_create
    end
  end

  describe '#expired?' do
    it "returns true if expired" do
      token.stub(:created_at).and_return(Time.now - 40.days)
      token.expired?.should == true
    end

    it "returns false if not expired" do
      token.stub(:created_at).and_return(Time.now - 20.days)
      token.expired?.should == false
    end
  end

  describe 'Token#destroy_expired' do
    it "calls Token.delete_all with a string and time" do
      Token.should_receive(:delete_all) do |array|
        array[0].should be_a(String)
        array[1].should be_a(Time)
      end
      Token.destroy_expired
    end
  end

  describe 'Token#generate_token_value' do
    it "generates random value using SecureRandom" do
      ActiveSupport::SecureRandom.should_receive(:hex).with(20)
      Token.generate_token_value
    end
  end

  describe '#delete_previous_tokens' do
    it 'Calls Token.delete_all with a string, integer, and action' do
      Token.should_receive(:delete_all) do |string, id, action|
        string.should be_a(String)
        id.should be_a(Integer)
        action.should be_a(Object)
      end
      token.send(:delete_previous_tokens)
    end
  end
end
