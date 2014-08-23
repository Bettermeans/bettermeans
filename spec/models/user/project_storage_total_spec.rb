require 'spec_helper'

describe User, '#project_storage_total' do

  let(:user) { Factory.build(:user) }

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
