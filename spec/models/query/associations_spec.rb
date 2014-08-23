require 'spec_helper'

describe Query, 'associations' do

  it { should belong_to(:project) }
  it { should belong_to(:user) }

end
