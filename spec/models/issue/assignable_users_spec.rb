require 'spec_helper'

describe Issue, '#assignable_users' do

  let(:project) { Factory.create(:project) }
  let(:issue) { Factory.create(:issue, :project => project) }
  let(:user) { Factory.create(:user) }

  before(:each) { user.add_as_core(project) }

  it 'returns the assignable users for the associated project' do
    issue.assignable_users.should == [user]
  end

end
