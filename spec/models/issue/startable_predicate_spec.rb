require 'spec_helper'

describe Issue, '#startable?' do

  let(:project) { Factory.create(:project) }
  let(:issue) { Factory.create(:issue, :project => project, :status => IssueStatus.open) }

  context 'when the issue has no "pri"' do
    it 'returns false' do
      issue.stub(:points_from_credits).and_return(50)
      issue.status = IssueStatus.open
      issue.pri = nil
      issue.save!
      issue.startable?.should be false
    end
  end

end
