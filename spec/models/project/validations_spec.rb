require 'spec_helper'

describe Project, 'validations' do

  it { should validate_presence_of(:name) }

  it { should ensure_length_of(:name).is_at_most(50) }
  it { should ensure_length_of(:homepage).is_at_most(255) }

end
