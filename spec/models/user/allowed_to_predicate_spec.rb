require 'spec_helper'

describe User, '#allowed_to?' do

  let(:user) { Factory.create(:user) }
  let(:admin_user) { Factory.create(:admin_user) }

  context "when a project is given" do

    it "returns false when the project is archived and the action is not unarchive" do
      project = Factory.create(:project, :status => Project::STATUS_ARCHIVED)
      user.allowed_to?({:action => 'foo'}, project).should be false
    end

    context "when the user is admin and the project allows the action" do

      let(:action) { :view_issues }

      it "returns true when the project is active" do
        project = Factory.build(:project, :status => Project::STATUS_ACTIVE)
        admin_user.allowed_to?(action, project).should be true
      end

      it "returns true when the project is locked" do
        project = Factory.build(:project, :status => Project::STATUS_LOCKED)
        admin_user.allowed_to?(action, project).should be true
      end

      it "returns true when the project is archived and the action is unarchive" do
        project = Factory.build(:project, :status => Project::STATUS_ARCHIVED)
        action = {:controller => "projects", :action => "unarchive" }
        admin_user.allowed_to?(action, project).should be true
      end

      it "returns false when the project is archived and the action is not unarchive" do
        project = Factory.build(:project, :status => Project::STATUS_ARCHIVED)
        admin_user.allowed_to?(action, project).should be false
      end
    end

    it "returns false when the user is admin and the project does not allow the action" do
      project = Factory.build(:project, :status => Project::STATUS_ACTIVE)
      admin_user.allowed_to?(:do_something, project).should be false
    end

    it "returns false when there is no role that allows the given action" do
      project = Factory.create(:project)
      user.allowed_to?(:edit_project, project).should be false
    end

    it "returns nil when the user is not allowed to see the project" do
      project = Factory.create(:project, :is_public => false)
      user.allowed_to?(:view_issues, project).should be nil
    end

    it "returns true when there is a role that allows the given action and the user can see the project" do
      project = Factory.create(:project)
      user.allowed_to?(:view_issues, project).should be true
    end
  end

  context "when given the :global option" do

    it "returns true when the user is admin" do
      admin_user.allowed_to?(:do_anything, nil, :global => true).should be true
    end

    it "returns true when the user has a project role that allows the action" do
      project = Factory.create(:project, :is_public => false)
      user.add_to_project(project, Role.member)
      user.allowed_to?(:edit_wiki_pages, nil, :global => true).should be true
    end

    it "returns true when the non-member role allows the action and user is logged in" do
      user.allowed_to?(:add_project, nil, :global => true).should be true
    end

    it "returns true when the anonymous role allows the action and user is anonymous" do
      User.anonymous.allowed_to?(:view_issues, nil, :global => true).should be true
    end

    it "returns false when no role allows the given action" do
      user.allowed_to?(:edit_wiki_pages, nil, :global => true).should be false
    end

  end

  context "when given no project and no :global option" do

    it "returns true when the user is admin" do
      admin_user.allowed_to?(:do_anything, nil).should be true
    end

    it "returns false when the user is not admin" do
      user.allowed_to?(:do_anything, nil).should be false
    end
  end
end
