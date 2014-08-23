require 'spec_helper'

describe Query, 'validations' do

  it { should validate_presence_of(:name) }
  it { should ensure_length_of(:name).is_at_most(255) }

end
