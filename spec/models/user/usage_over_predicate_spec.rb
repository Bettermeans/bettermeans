require 'spec_helper'

describe User, '#usage_over?' do

  let(:plan) do
    Factory.create(
      :plan,
      :storage_max => 100,
      :private_workstream_max=> 1,
      :contributor_max => 1
    )
  end
  let(:user) { Factory.create(:user, :plan => plan) }

  it "returns true when project storage total exceeds plan limit" do
    Factory.create(:project, :owner => user, :storage => 101)
    user.usage_over?.should be true
  end

  it "returns true when private project total exceeds plan limit" do
    Factory.create(:project, :owner => user, :is_public => false)
    Factory.create(:project, :owner => user, :is_public => false)
    user.usage_over?.should be true
  end

  it "returns true when private contributors exceed plan limit" do
    project = Factory.create(:project, :owner => user, :is_public => false)
    Factory.create(:user).add_as_member(project)
    Factory.create(:user).add_as_member(project)
    user.usage_over?.should be true
  end

  it "returns false when no plan limits are exceeded" do
    project = Factory.create(:project, :owner => user, :is_public => false, :storage => 100)
    Factory.create(:user).add_as_member(project)
    user.usage_over?.should be false
  end

end