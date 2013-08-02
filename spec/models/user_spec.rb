require 'spec_helper'

describe User do
  subject { User.new }

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
    context "when given nil" do
      it "does not change first & last name" do
        user = User.new
        user.firstname = 'firstname'
        user.lastname = 'lastname'
        user.fullname=(nil)
        user.firstname.should == 'firstname'
        user.lastname.should == 'lastname'
      end
    end

    context "when given a string" do
      it "assigns first and last names" do
        user = User.new
        user.firstname = 'firstname'
        user.lastname = 'lastname'
        user.fullname = 'full name'
        user.firstname.should == 'full'
        user.lastname.should == 'name'
      end
    end
  end

  # registered? method
  describe "#registered?" do
    let(:user) { User.new } # memoizes the user object

    context "when user status is registered" do    
      it "returns true" do # describe specifically the expected test results
        # user.status = 2 # connaissance of meaning - commented out in favor of better test below
        # user.registered?.should == true
        user.status = User::STATUS_REGISTERED # connaissance of name is more specific
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

end
