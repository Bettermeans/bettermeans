require 'spec_helper'

describe Token, '.destroy_expired' do

  let(:token) { Token.create!({:action => 'test'}) }

  before(:each) { token.user_id = 1 }

  it "deletes expired tokens" do
    token.created_at = Time.now - 20.days
    token.save
    Token.destroy_expired
    Token.find_by_id(token.id).should == token
    token.created_at = Time.now - 40.days
    token.save
    Token.destroy_expired
    Token.find_by_id(token.id).should == nil
  end

end
