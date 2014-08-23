require 'spec_helper'

describe Journal, '#project' do

  context 'when journalized does not have a project' do
    it 'returns nil' do
      journal = Journal.new({:journalized_id => nil})
      journal.project.should be_nil
    end
  end

end
