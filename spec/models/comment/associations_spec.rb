require 'spec_helper'

describe Comment, 'associations' do

  it { should belong_to(:author) }
  it { should belong_to(:commented) }

end
