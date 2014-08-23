require 'spec_helper'

describe Credit, 'associations' do

  it { should belong_to(:owner) }
  it { should belong_to(:project) }

end
