require 'spec_helper'

describe User, '#member_of?' do

  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }

  it "returns true when user is a member of the project" do
    user.add_as_member(project)
    user.member_of?(project).should be true
  end

  it "returns false when the user is not a member of the project" do
    user.member_of?(project).should be false
  end

  it "returns false when the user has another role with the project" do
    user.add_as_contributor(project)
    user.member_of?(project).should be false
  end

  it "returns false when the user is anonymous" do
    User.anonymous.member_of?(project).should be false
  end

end
