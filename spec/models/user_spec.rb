require 'spec_helper'

describe User do

  let(:user) { Factory.build(:user) }

  it { should have_many(:members).dependent(:destroy) }
  it { should have_many(:memberships) }
  it { should have_many(:core_memberships) }
  it { should have_many(:active_memberships) }
  it { should have_many(:projects).through(:memberships) }
  it { should have_many(:owned_projects) }
  it { should have_many(:invitations) }
  it { should have_many(:activity_streams).dependent(:delete_all) }

  it { should have_one(:preference).dependent(:destroy) }
  it { should have_one(:rss_token).dependent(:destroy) }
  it { should have_one(:api_token).dependent(:destroy) }

  it { should belong_to(:auth_source) }
  it { should belong_to(:plan) }

  it { should have_many(:notifications).dependent(:delete_all) }
  it { should have_many(:credits) }
  it { should have_many(:issue_votes).dependent(:delete_all) }
  it { should have_many(:authored_todos) }
  it { should have_many(:owned_todos) }
  it { should have_many(:outgoing_ratings) }
  it { should have_many(:incoming_ratings) }
  it { should have_many(:credit_distributions) }
  it { should have_many(:reputations).dependent(:delete_all) }
  it { should have_many(:help_sections) }
  it { should have_many(:tokens) }

  describe "#fullname=" do
    before(:each) do
      user.firstname = 'firstname'
      user.lastname = 'lastname'
    end

    context "when given nil" do
      it "does not change first & last name" do
        user.fullname = nil
        user.firstname.should == 'firstname'
        user.lastname.should == 'lastname'
      end
    end

    context "when given a string" do
      it "assigns first and last names" do
        user.fullname = 'full name'
        user.firstname.should == 'full'
        user.lastname.should == 'name'
      end
    end
  end

  describe "#active?" do
    let(:user) { User.new }

    context "when user status is active" do
      it "returns true" do
        user.status = User::STATUS_ACTIVE
        user.should be_active
      end
    end

    context "when user status is not active" do
      it "returns false" do
        user.status = User::STATUS_CANCELED
        user.should_not be_active
      end
    end
  end

  describe "#registered?" do
    let(:user) { User.new }

    context "when user status is registered" do
      it "returns true" do
        user.status = User::STATUS_REGISTERED
        user.should be_registered
      end
    end

    context "when user status is not registered" do
      it "returns false" do
        user.status = User::STATUS_ACTIVE
        user.should_not be_registered
      end
    end
  end

  describe "#canceled?" do
    let(:user) { User.new }

    context "when user status is canceled" do
      it "returns true" do
        user.status = User::STATUS_CANCELED
        user.should be_canceled
      end
    end

    context "when user status is not canceled" do
      it "returns false" do
        user.status = User::STATUS_ACTIVE
        user.should_not be_canceled
      end
    end
  end

  describe "#locked?" do
    let (:user) { User.new }

    context "when user status is locked" do
      it "returns true" do
        user.status = User::STATUS_LOCKED
        user.should be_locked
      end
    end

    context "when user status is not locked" do
      it "returns false" do
        user.status = User::STATUS_ACTIVE
        user.should_not be_locked
      end
    end
  end

  describe '#belongs_to_projects' do
    it 'does something' do
      user.belongs_to_projects
    end
  end

  describe '#project_storage_total' do
    it 'defaults to zero' do
      user.project_storage_total.should == 0
    end

    context 'when there are owned projects' do
      it 'sums up the storage for the projects' do
        fake_project = stub(:storage => 5)
        user.stub(:owned_projects).and_return([fake_project])
        user.project_storage_total.should == 5
      end
    end
  end

end
