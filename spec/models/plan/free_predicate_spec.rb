require 'spec_helper'

describe Plan, '#free?' do

  let(:plan) { Plan.new }

  context 'when the plan is free' do
    it 'returns true' do
      plan.code = Plan::FREE_CODE
      plan.free?.should be true
    end
  end

  context 'when the plan is not free' do
    it 'returns false' do
      plan.code = 5
      plan.free?.should be false
    end
  end

end
