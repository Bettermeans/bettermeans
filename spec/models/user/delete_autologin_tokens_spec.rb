require 'spec_helper'

describe User, '#delete_autologin_tokens' do

  let(:user) { Factory.create(:user) }

  it "deletes all autologin tokens associated with the user" do
    token1 = Factory.create(:token, :user => user, :action => "autologin")
    token2 = Factory.create(:token, :user => user, :action => "autologin")

    user.delete_autologin_tokens

    Token.find_by_id(token1.id).should be nil
    Token.find_by_id(token2.id).should be nil
  end

  it "does not delete other tokens associated with the user" do
    token1 = Factory.create(:token, :user => user, :action => "feeds")
    token2 = Factory.create(:token, :user => user, :action => "boogers")

    user.delete_autologin_tokens

    Token.find_by_id(token1.id).should == token1
    Token.find_by_id(token2.id).should == token2
  end

  it "does not delete autologin tokens for other users" do
    token1 = Factory.create(:token, :action => "autologin")
    token2 = Factory.create(:token, :action => "autologin")

    user.delete_autologin_tokens

    Token.find_by_id(token1.id).should == token1
    Token.find_by_id(token2.id).should == token2
  end

end