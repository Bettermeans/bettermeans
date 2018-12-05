require 'spec_helper'

describe User, '#core_member_of?' do

  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }

  it "returns true when user is a core member of the project" do
    user.add_to_project(project, Role.core_member)
    user.core_member_of?(project).should be true
  end

  it "returns false when the user has no roles for the project" do
    user.core_member_of?(project).should be false
  end

  it "returns false when the user is not a core member of the project" do
    user.add_to_project(project, Role.contributor)
    user.core_member_of?(project).should be false
  end

  it "returns false when the user is anonymous" do
    User.anonymous.core_member_of?(project).should be false
  end

end