require 'spec_helper'

describe User, '#position_for' do

  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }

  it "returns the position of the role when the user has one role" do
    user.add_to_project(project, Role.clearance)
    user.position_for(project).should == 7
  end

  it "returns the smallest position when the user has more than one role" do
    user.add_to_project(project, Role.clearance)
    user.add_to_project(project, Role.contributor)
    user.add_to_project(project, Role.administrator)
    user.position_for(project).should == 4
  end

  it "returns nil when the project is not active" do
    project.lock
    user.position_for(project).should be nil
  end

  it "returns the anonymous position when the user is anonymous" do
    User.anonymous.position_for(project).should == 9
  end
end
