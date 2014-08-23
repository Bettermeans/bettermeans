require 'spec_helper'

describe Journal, '#attachments' do

  context 'when journalized does not have attachments' do
    it 'returns nil' do
      journal = Journal.new({:journalized_id => nil})
      journal.attachments.should be_nil
    end
  end

end
