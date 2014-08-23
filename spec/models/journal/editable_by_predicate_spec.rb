require 'spec_helper'

describe Journal, '#editable_by?' do

  context 'when usr is nil' do
    it 'returns false' do
      journal = Journal.new
      journal.editable_by?(nil).should be false
    end
  end

end
