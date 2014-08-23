require 'spec_helper'

describe News, 'validations' do

  it { should belong_to(:project) }
  it { should belong_to(:author) }

  it { should ensure_length_of(:title).is_at_most(60) }
  it { should ensure_length_of(:summary).is_at_most(255) }

end
