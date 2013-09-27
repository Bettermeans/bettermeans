require 'spec_helper'

describe Issue do
  it { should belong_to(:project) }
  it { should belong_to(:tracker) }
  it { should belong_to(:status).class_name('IssueStatus') }
  it { should belong_to(:author).class_name('User') }
  it { should belong_to(:assigned_to).class_name('User') }
  it { should belong_to(:retro) }
  it { should belong_to(:hourly_type) }
  it { should have_many(:journals).dependent(:destroy) }
  it { should have_many(:relations_from).class_name('IssueRelation') }
  it { should have_many(:relations_to).class_name('IssueRelation') }
  it { should have_many(:issue_votes).dependent(:delete_all) }
  it { should have_many(:todos).dependent(:delete_all) }


end
