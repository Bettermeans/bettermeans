require "spec_helper"

describe Project do

  let(:project) { Project.new }

  describe 'associations' do
    it { should belong_to(:enterprise) }
    it { should belong_to(:owner) }

    it { should have_many(:all_members) }
    it { should have_many(:administrators) }
    it { should have_many(:core_members) }
    it { should have_many(:members) }
    it { should have_many(:board_members) }
    it { should have_many(:contributors) }
    it { should have_many(:binding_members) }
    it { should have_many(:enterprise_members) }
    it { should have_many(:member_users) }
    it { should have_many(:users).through(:all_members) }
    it { should have_many(:credit_distributions).dependent(:delete_all) }
    it { should have_many(:enabled_modules).dependent(:delete_all) }
    it { should have_and_belong_to_many(:trackers) }
    it { should have_many(:issues) }
    it { should have_many(:issue_votes).through(:issues) }
    it { should have_many(:issue_changes).through(:issues) }
    it { should have_many(:queries).dependent(:delete_all) }
    it { should have_many(:documents).dependent(:destroy) }
    it { should have_many(:news).dependent(:delete_all) }
    it { should have_many(:boards).dependent(:destroy) }
    it { should have_many(:messages).through(:boards) }
    it { should have_many(:shares).dependent(:delete_all) }
    it { should have_many(:credits).dependent(:delete_all) }
    it { should have_many(:retros).dependent(:delete_all) }
    it { should have_many(:reputations).dependent(:delete_all) }
    it { should have_many(:motions).dependent(:delete_all) }
    it { should have_many(:hourly_types).dependent(:delete_all) }
    it { should have_many(:activity_streams).dependent(:delete_all) }
    it { should have_many(:invitations).dependent(:delete_all) }

    it { should have_one(:wiki).dependent(:destroy) }
  end

  describe '#valid?' do
    it { should validate_presence_of(:name) }
    it { should ensure_length_of(:name).is_at_most(50) }
    it { should ensure_length_of(:homepage).is_at_most(255) }
  end

  describe '#project_id' do
    context 'when project is not nil' do
      project = Project.create!(:name => "New Project")

      it 'returns Project instance id' do
        project.project_id.should == project.id
      end
    end
  end

  describe ".visible_by" do
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

    describe User.anonymous, "user type" do
      it "has zero memberships" do
        User.anonymous.memberships.any?.should be_false
      end

      it "is not admin" do
        User.anonymous.admin?.should be_false
      end
    end
  end

  describe ".latest_public" do
    it "only queries for root projects, i.e., projects that are not children of other projects" do
      fake_named_scope = mock("Fake named scope")
      fake_named_scope.stub(:find).with(any_args)

      Project.should_receive(:all_roots).once.and_return fake_named_scope
      # Project.should_not_receive(:all_children)

      Project.latest_public fake_admin
    end

    def fake_admin
      result = mock("A fake admin")
      # result.stub(:admin?).and_return true
      result
    end
  end

  describe ".most_active_public" do
    it "only queries for root projects, i.e., projects that are not children of other projects" do
      fake_named_scope = mock("Fake named scope")
      fake_named_scope.stub(:find).with(any_args)

      Project.should_receive(:all_roots).once.and_return fake_named_scope
      # Project.should_not_receive(:all_children)

      Project.most_active_public fake_admin
    end

    def fake_admin
      result = mock("A fake admin")
      # result.stub(:admin?).and_return true
      result
    end
  end

  describe '#activities' do
    include_inactive = false

    context 'if include_inactive is true' do
      include_inactive = true
      it 'returns all_activities' do
        # project.activities.should == all_activities
      end
    end

    context 'if include_inactive is false' do
      it 'returns only active_activities' do
        # project.activities.should == active_activities
      end
    end
  end

  describe '#active?' do
    context 'if status is STATUS_ACTIVE' do
      it 'returns true' do
        project.status = Project::STATUS_ACTIVE
        project.active?.should be_true
      end
    end
    context 'if status is not STATUS_ACTIVE' do
      it 'returns false' do
        project.status = Project::STATUS_ARCHIVED
        project.active?.should be_false
      end
    end
  end

  describe '#archived?' do
    context 'if status is STATUS_ARCHIVED' do
      it 'returns true' do
        project.status = Project::STATUS_ARCHIVED
        project.archived?.should be_true
      end
    end
    context 'if status is not STATUS_ARCHIVED' do
      it 'returns false' do
        project.status = Project::STATUS_ACTIVE
        project.archived?.should be_false
      end
    end
  end

  describe '#locked?' do
    context 'if status is STATUS_LOCKED' do
      it 'returns true' do
        project.status = Project::STATUS_LOCKED
        project.locked?.should be_true
      end
    end
    context 'if status is not STATUS_LOCKED' do
      it 'returns false' do
        project.status = Project::STATUS_ARCHIVED
        project.locked?.should be_false
      end
    end
  end

  describe '#lock' do
    project = Factory.create(:project)
    project.status = Project::STATUS_ACTIVE

    context 'if status is active and not currently locked' do
      it 'should lock the project and return true' do
        expect {
          project.lock
        }.to change{
          project.status
        }.from(Project::STATUS_ACTIVE).to(Project::STATUS_LOCKED)
      end
    end
  end

  describe '#unlock' do
    project = Factory.create(:project)
    project.status = Project::STATUS_LOCKED

    context 'if status is currently locked' do
      it 'should unlock the project and return true' do
        expect {
          project.unlock
        }.to change{
          project.status
        }.from(Project::STATUS_LOCKED).to(Project::STATUS_ACTIVE)
      end
    end
  end

  describe '#enterprise?' do
    context 'when parent_id is nil' do
      it 'returns true' do
        project.should be_enterprise
      end
    end

    context 'when parent_id is not nil' do
      it 'returns false' do
        project1 = Factory.create(:project)
        project2 = Factory.create(:project)
        project2.move_to_child_of(project1)
        project2.should_not be_enterprise
      end
    end
  end

  # describe '#archive' do
  #   it 'returns true upon successful archive of Project trnsactions' do

  #   end
  # end

  describe '#active_members' do
    it 'returns hash of active project users' do
      members = project.all_members.find(:all, :conditions => "roles.builtin = #{Role::BUILTIN_ACTIVE}")
      p project.all_members
      project.active_members.should == members
    end
  end

  describe '#clearance_members' do
    it 'returns hash of project users with clearance' do
      members = project.all_members.find(:all, :conditions => "roles.builtin = #{Role::BUILTIN_CLEARANCE}")
      p project.clearance_members
      project.clearance_members.should == members
    end
  end
end
