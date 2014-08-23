require 'spec_helper'

describe Token, '#expired?' do

  let(:token) { Token.create!({:action => 'test'}) }

  before(:each) { token.user_id = 1 }

  it "returns true if expired" do
    token.created_at = Time.now - 40.days
    token.expired?.should be true
  end

  it "returns false if not expired" do
    token.created_at = Time.now - 20.days
    token.expired?.should be false
  end

end
