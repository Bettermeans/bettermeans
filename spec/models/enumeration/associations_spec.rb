require 'spec_helper'

describe Enumeration, 'associations' do

  it { should belong_to(:project) }

end
