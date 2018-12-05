require 'spec_helper'

describe User, '#contributor_of?' do

  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }

  it "returns true when the user is a contributor to the project" do
    user.add_to_project(project, Role.contributor)
    user.contributor_of?(project).should be true
  end

  it "returns false when the user has no roles for the project" do
    user.contributor_of?(project).should be false
  end

  it "returns false when the user has a non-contributor role for the project" do
    user.add_to_project(project, Role.member)
    user.contributor_of?(project).should be false
  end

  it "returns false when the user is anonymous" do
    User.anonymous.contributor_of?(project).should be false
  end

end