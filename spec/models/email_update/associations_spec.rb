require 'spec_helper'

describe EmailUpdate, 'associations' do

  it { should belong_to(:user) }

end
