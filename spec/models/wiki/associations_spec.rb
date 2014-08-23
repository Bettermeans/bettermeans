require 'spec_helper'

describe Wiki, 'associations' do

  it { should belong_to(:project) }

  it { should have_many(:pages).dependent(:destroy) }
  it { should have_many(:redirects).dependent(:delete_all) }

end
