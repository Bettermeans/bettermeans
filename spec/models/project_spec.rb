require "spec_helper"

describe Project,"#visible_by" do
  fake_user = Class.new do
    def initialize(admin = false, memberships = [])
      @admin,@memberships = admin,memberships
    end

    def admin?; @admin; end
    def memberships; @memberships end
  end

  describe "given user is admin" do
    it "returns project status filter if user is admin" do
      result = Project.visible_by fake_user.new true
      result.should eql "projects.status=1"
    end

    it "returns project status and publicity filter if user is not supplied" do
      result = Project.visible_by
      result.should eql "projects.status=1 AND projects.is_public = 't'"
    end

    it "returns project status and publicity filter if user supplied as nil" do
      result = Project.visible_by nil
      result.should eql "projects.status=1 AND projects.is_public = 't'"
    end
  end

  describe "given user is not admin and has memberships" do
    it "returns project status and either public or memberof filter" do
      membership = Member.new
      membership.project_id = 1337

      user = fake_user.new false, [membership]

      result = Project.visible_by user

      result.should eql "projects.status=1 AND " +
        "(projects.is_public = 't' or projects.id IN (#{membership.project_id}))"
    end
  end

  describe "given user is not admin and has no memberships" do
    it "returns project status and publicity filter" do
      a_user_that_is_not_admin_and_has_no_memberships = fake_user, false, []
      result = Project.visible_by User.anonymous
      result.should eql "projects.status=1 AND projects.is_public = 't'"
    end
  end
end

describe Project,"#latest_public" do
  it "only queries for root projects, i.e., projects that are not children of other projects" do
    fake_named_scope = mock("Fake named scope")
    fake_named_scope.stub(:find).with(any_args)

    Project.should_receive(:all_roots).once.and_return fake_named_scope
    Project.should_not_receive(:all_children)

    Project.latest_public fake_admin
  end

  def fake_admin
    result = mock("A fake admin")
    result.stub(:admin?).and_return true
    result
  end
end

describe Project,"#most_active_public" do
  it "only queries for root projects, i.e., projects that are not children of other projects" do
    fake_named_scope = mock("Fake named scope")
    fake_named_scope.stub(:find).with(any_args)

    Project.should_receive(:all_roots).once.and_return fake_named_scope
    Project.should_not_receive(:all_children)

    Project.most_active_public fake_admin
  end

  def fake_admin
    result = mock("A fake admin")
    result.stub(:admin?).and_return true
    result
  end
end

describe User.anonymous," user type" do
  it "has zero memberships" do
    User.anonymous.memberships.any?.should be_false
  end

  it "is not admin" do
    User.anonymous.admin?.should be_false
  end
end
