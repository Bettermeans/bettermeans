require 'spec_helper'

describe Journal, '#new_status' do

  context 'when no related details exist with status_id prop_key' do
    it 'returns nil' do
      journal = Journal.new
      journal.new_status.should be_nil
    end
  end

end
