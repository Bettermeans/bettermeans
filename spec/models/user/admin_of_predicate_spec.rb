require 'spec_helper'

describe User, '#admin_of?' do

  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }

  it "returns true when user is the admin for the project" do
    user.add_to_project(project, Role.administrator)
    user.admin_of?(project).should be true
  end

  it "returns false when the user has no roles for the project" do
    user.admin_of?(project).should be false
  end

  it "returns false when the user has a non-admin role for the project" do
    user.add_as_contributor(project)
    user.admin_of?(project).should be false
  end

  it "returns false when the user is anonymous" do
    User.anonymous.admin_of?(project).should be false
  end

end
