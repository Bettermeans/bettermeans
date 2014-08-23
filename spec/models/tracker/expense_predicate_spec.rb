require 'spec_helper'

describe Tracker, '#expense?' do

  let(:tracker) { Tracker.new }

  context 'when the name is Expense' do
    it 'returns true' do
      tracker.name = 'Expense'
      tracker.expense?.should be true
    end
  end

  context 'when the name is not Expense' do
    it 'returns false' do
      tracker.name = 'not_expense'
      tracker.expense?.should be false
    end
  end

end
