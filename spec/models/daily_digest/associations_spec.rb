require 'spec_helper'

describe DailyDigest, 'associations' do

  it { should belong_to(:issue) }
  it { should belong_to(:journal) }

end
