require 'spec_helper'

describe User, '#to_s' do

  let(:user) { User.new(:firstname => "Sally", :lastname => "Boogerpants") }

  it "returns the user's name" do
    user.to_s.should == "Sally Boogerpants"
  end

end
