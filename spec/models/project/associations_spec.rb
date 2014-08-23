require 'spec_helper'

describe Project, 'associations' do

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
  it { should have_many(:projects_trackers) }
  it { should have_many(:trackers).through(:projects_trackers) }
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
