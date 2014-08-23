require 'spec_helper'

describe Journal, 'associations' do

  it { should belong_to(:journalized) }
  it { should belong_to(:issue) }
  it { should belong_to(:user) }

  it { should have_many(:details) }

end
