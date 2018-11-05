require 'spec_helper'

describe User, '#community_member_of?' do

  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }

  it "returns true when user has a community member role for the project" do
    user.add_as_member(project)
    user.community_member_of?(project).should be true
  end

  it "returns false when the user has no roles for the project" do
    user.community_member_of?(project).should be false
  end

  it "returns false when the user is anonymous" do
    User.anonymous.community_member_of?(project).should be false
  end

end
