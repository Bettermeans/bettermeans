require 'spec_helper'

describe Journal do

  describe 'associations' do
    it { should belong_to(:journalized) }
    it { should belong_to(:issue) }
    it { should belong_to(:user) }

    it { should have_many(:details) }
  end

  describe '#update_issue_timestamp' do
    it 'updates timestamp for journal.issue' do
      time = Time.now
      DateTime.stub(:now).and_return(time)
      journal = Journal.create!({ :issue => Issue.new, :journalized_type => "Issue" })
      journal.journalized_id = 5
      journal.update_issue_timestamp
      journal.issue.updated_at.should == time
    end
  end

  describe '#issue_id' do
    let(:journal) { Journal.new }
    it 'returns journalized_id' do
      journal.journalized_id = 1
      journal.issue_id.should == 1
    end
  end

end
