require 'spec_helper'

describe Issue, '#push_allowed?' do

  let(:issue) { Factory.create(:issue) }
  let(:user) { Factory.create(:user) }

  it 'returns false if the given user is nil' do
    issue.push_allowed?(nil).should be false
  end

  it 'returns true if issue is assigned to the given user' do
    issue.update_attributes!(:assigned_to => user)
    issue.push_allowed?(user).should be true
  end

end
