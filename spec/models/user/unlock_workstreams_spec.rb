require 'spec_helper'

describe User, '#unlock_workstreams' do

  let(:user) { Factory.build(:user) }

  context "when usage is not beyond grace period" do

    it "unlocks private projects owned by the user" do
      project = Factory.create(
        :project,
        :owner => user,
        :is_public => false,
        :status => Project::STATUS_LOCKED
      )
      expect do
        user.unlock_workstreams
      end.to change{project.reload.locked?}.from(true).to(false)
    end

    it "does unlock public projects owned by the user" do
      project = Factory.create(
        :project,
        :owner => user,
        :is_public => true,
        :status => Project::STATUS_LOCKED
      )
      expect do
        user.unlock_workstreams
      end.to change{project.reload.locked?}.from(true).to(false)
    end

    it "does not unlock private projects the user is a member of" do
      project = Factory.create(
        :project,
        :is_public => false,
        :status => Project::STATUS_LOCKED
      )
      user.add_as_member(project)
      expect do
        user.unlock_workstreams
      end.to_not change{project.reload.locked?}.from(true)
    end

  end

  it "does not unlock private projects owned by the user when usage is over" do
    user.usage_over_at = 31.day.ago
    project = Factory.create(
      :project,
      :owner => user,
      :is_public => false,
      :status => Project::STATUS_LOCKED
    )
    expect do
      user.unlock_workstreams
    end.to_not change{project.reload.locked?}.from(true)
  end

end
