require 'spec_helper'

describe User, '#pref' do

  let(:user) { User.new }

  it "returns the user's preference when it already exists" do
    user_preference = UserPreference.new
    user.preference = user_preference
    user.pref.should == user_preference
  end

  it "instantiates a new user preference when it does not exist" do
    user_preference = user.pref
    user_preference.should be_new_record
    user_preference.user.should == user
  end

end
