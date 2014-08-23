require 'spec_helper'

describe Journal, '#save' do

  context 'when there are no details and no notes' do
    it 'returns false' do
      journal = Journal.new
      journal.save.should be false
    end
  end

end
