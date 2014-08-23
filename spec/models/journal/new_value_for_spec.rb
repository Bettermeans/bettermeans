require 'spec_helper'

describe Journal, '#new_value_for' do

  context 'when a related detail is not found for the given property' do
    it 'returns nil' do
      journal = Journal.new
      journal.new_value_for('property').should be_nil
    end
  end

end
