require 'spec_helper'

describe User, '#api_key' do

  let(:user) { Factory.build(:user) }

  it "returns the value of the user's api_token when it already exists" do
    token = Factory.create(:token, :user => user, :action => "api")
    user.api_key.should == token.value
  end

 it "returns the value of a newly created token when it doesn't already exist" do
    api_key = nil
    expect do
      api_key = user.api_key
    end.to change(Token, :count).by(1)
    Token.find(:first, :order => "id DESC").value.should == api_key
  end

end