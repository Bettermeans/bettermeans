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
end
