require 'spec_helper'

describe User, '.find_by_rss_key' do

  let(:user) { Factory.build(:user) }
  let(:token) { Factory.create(:token, :user => user, :action => "feeds") }

  it "returns nil when no token is found" do
    User.find_by_rss_key("blah").should be nil
  end

  it "returns nil when token's user is not active" do
    user.lock
    User.find_by_rss_key(token.value).should be nil
  end

  it "returns user when token is found and user is active" do
    User.find_by_rss_key(token.value).should == user
  end

end
