require 'spec_helper'

describe Plan do
  describe '#free?' do
    let(:plan) { Plan.new }

    context 'when the plan is free' do
      it 'returns true' do
        plan.code = Plan::FREE_CODE
        plan.should be_free
      end
    end

    context 'when the plan is not free' do
      it 'returns false' do
        plan.code = 5
        plan.should_not be_free
      end
    end
  end

  describe '.free' do
    it 'returns a free plan' do
      Plan.free.should be_free
    end
  end
end
