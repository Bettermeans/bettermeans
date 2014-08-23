require 'spec_helper'

describe Journal, '#parse_relations_delayed' do

  context "when notes is nil" do
    it 'does not create an IssueRelation' do
      journal = Journal.new(:notes => nil)
      expect {
        journal.parse_relations_delayed
      }.to_not change(IssueRelation, :count)
    end
  end

end
