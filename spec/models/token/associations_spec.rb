require 'spec_helper'

describe Token, 'associations' do

  it { should belong_to(:user) }

end
