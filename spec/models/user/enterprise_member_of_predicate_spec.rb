require 'spec_helper'

describe User, '#enterprise_member_of?' do

  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }

  it "returns true when user has an enterprise role for the project" do
    user.add_as_member(project)
    user.enterprise_member_of?(project).should be true
  end

  it "returns false when the user has no roles for the project" do
    user.enterprise_member_of?(project).should be false
  end

  it "returns false when the user is anonymous" do
    User.anonymous.enterprise_member_of?(project).should be false
  end

  it "returns false when the user has an active role for the project" do
    user.add_to_project(project, Role.active)
    user.enterprise_member_of?(project).should be false
  end

end
