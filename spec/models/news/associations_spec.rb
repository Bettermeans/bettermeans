require 'spec_helper'

describe News, 'associations' do

  it { should have_many(:comments).dependent(:delete_all) }

end
