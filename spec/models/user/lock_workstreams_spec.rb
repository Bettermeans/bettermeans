require 'spec_helper'

describe User, '#lock_workstreams' do

  let(:user) { Factory.build(:user) }

  it "does not lock projects when usage is not over" do
    project = Factory.create(:project, :owner => user, :is_public => false)
    expect do
      user.lock_workstreams
    end.to_not change{project.reload.locked?}.from(false)
  end

  context "when usage is beyond grace period" do

    before { user.usage_over_at = 31.days.ago }

    it "locks private projects owned by the user" do
      project = Factory.create(:project, :owner => user, :is_public => false)
      expect do
        user.lock_workstreams
      end.to change{project.reload.locked?}.from(false).to(true)
    end

    it "does not lock public projects owned by the user" do
      project = Factory.create(:project, :owner => user, :is_public => true)
      expect do
        user.lock_workstreams
      end.to_not change{project.reload.locked?}.from(false)
    end

    it "does not lock private projects the user is a member of" do
      project = Factory.create(:project, :is_public => false)
      user.add_as_member(project)
      expect do
        user.lock_workstreams
      end.to_not change{project.reload.locked?}.from(false)
    end

  end
end
