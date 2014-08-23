require 'spec_helper'

describe Plan, '.free' do

  it 'returns a free plan' do
    Plan.free.free?.should be true
  end

end
