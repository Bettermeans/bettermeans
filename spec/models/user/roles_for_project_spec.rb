require 'spec_helper'

describe User, '#roles_for_project' do

  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }

  it "returns an empty array when the project is not active" do
    project = Factory.create(:project, :status => Project::STATUS_LOCKED)
    user.roles_for_project(project).should == []
  end

  context "when the user is logged in" do

    it "returns roles for the root project when given a child project" do
      child_project = Factory.create(:project)
      child_project.move_to_child_of(project)
      user.add_as_contributor(child_project)
      user.add_as_member(project)
      user.roles_for_project(child_project).should == [Role.member]
    end

    it "returns their membership roles when they are a member of the project" do
      user.add_as_contributor(project)
      user.roles_for_project(project).should == [Role.contributor]
    end

    it "returns non-member role when they are not a member of the project" do
      user.roles_for_project(project).should == [Role.non_member]
    end
  end

  it "returns anonymous role when the user is not logged in" do
    User.anonymous.roles_for_project(project).should == [Role.anonymous]
  end

end
