require 'spec_helper'

describe User, '#<=>' do

  it "sorts records by string when they're both users" do
    user1 = User.new(:firstname => "sally")
    user2 = User.new(:firstname => "Zeke")
    user3 = User.new(:firstname => "bill")
    user4 = User.new(:firstname => "BILL")
    (user1 <=> user2).should == -1
    (user2 <=> user3).should == 1
    (user3 <=> user4).should == 0
  end

  it "sorts records by *reverse* class name when one is not a user" do
    (User.new <=> Issue.new).should be(-1)
    (User.new <=> Workflow.new).should be 1
  end

end
