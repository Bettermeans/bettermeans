require 'spec_helper'

describe User, '#rss_key' do

  let(:user) { Factory.build(:user) }

  it "returns the value of the user's rss_token when it already exists" do
    token = Factory.create(:token, :user => user, :action => "feeds")
    user.rss_key.should == token.value
  end

  it "returns the value of a newly created token when it doesn't already exist" do
    rss_key = nil
    expect do
      rss_key = user.rss_key
    end.to change(Token, :count).by(1)
    Token.find(:first, :order => "id DESC").value.should == rss_key
  end

end
