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
      issue = Issue.new
      issue.should_receive(:save)
      journal = Journal.new(:issue => issue)
      journal.update_issue_timestamp
      issue.updated_at.should == time
    end
  end

  describe '#send_mentions' do
    it 'delegates to Mention' do
      journal = Journal.new({:user_id => 5})
      Mention.should_receive(:parse).with(journal, 5)
      journal.send_mentions
    end
  end

  describe '#mention' do
    it 'creates a mention' do
      issue = Issue.new({:subject => 'something'})
      journal = Journal.new({:user_id => 5, :issue => issue})
      expect {
        journal.mention(5, 10, 'note')
      }.to change(Notification, :count).by(1)
    end
  end

  describe '#parse_relations' do
    it 'puts in a delayed job' do
      journal = Journal.new
      journal.should_receive(:send_later).with(:parse_relations_delayed)
      journal.parse_relations
    end
  end

  describe '#issue_id' do
    let(:journal) { Journal.new }
    it 'returns journalized_id' do
      journal.journalized_id = 1
      journal.issue_id.should == 1
    end
  end

  describe '#parse_relations_delayed' do
    context "when notes is nil" do
      it 'does not create an IssueRelation' do
        journal = Journal.new(:notes => nil)
        expect {
          journal.parse_relations_delayed
        }.to_not change(IssueRelation, :count)
      end
    end
  end

  describe '#save' do
    context 'when there are no details and no notes' do
      it 'returns false' do
        journal = Journal.new
        journal.save.should be_false
      end
    end
  end

  describe '#new_status' do
    context 'when no related details exist with status_id prop_key' do
      it 'returns nil' do
        journal = Journal.new
        journal.new_status.should be_nil
      end
    end
  end

  describe '#new_value_for' do
    context 'when a related detail is not found for the given property' do
      it 'returns nil' do
        journal = Journal.new
        journal.new_value_for('property').should be_nil
      end
    end
  end

  describe '#editable_by?' do
    context 'when usr is nil' do
      it 'returns false' do
        journal = Journal.new
        journal.editable_by?(nil).should be_false
      end
    end
  end

  describe '#project' do
    context 'when journalized does not have a project' do
      it 'returns nil' do
        journal = Journal.new({:journalized_id => nil})
        journal.project.should be_nil
      end
    end
  end

  describe '#attachments' do
    context 'when journalized does not have attachments' do
      it 'returns nil' do
        journal = Journal.new({:journalized_id => nil})
        journal.attachments.should be_nil
      end
    end
  end

end
